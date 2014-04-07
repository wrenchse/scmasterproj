s.options.memSize

(
//  B O O T --------------------------------------------------------------------- //

~fftsize=2048;
~reverbSend 	= 110;
~resonatorSend	= 100;
~ambiBus		= 120;

~fxG = Group.tail;
~sG = Group.new;


s.options.sampleRate	= 48000;
s.options.memSize		= 5000*1024;

s.waitForBoot{

	{
		// INITIATE REVERB IMPULSE RESPONSE

		var ir, irbuffers = Array.fill(4), bufsize;

		irbuffers.do {|b, i| // Load each of the channels to different buffers
			irbuffers[i] = Buffer.readChannel(s, "Hall1.wav".resolveRelative, channels: [i], numFrames: 48000)};
		s.sync;

		bufsize= PartConv.calcBufSize(~fftsize, irbuffers[0]).postln;

		~irspectra= Array.fill(4,{Buffer.alloc(s, bufsize, 1)});
		~irspectra.do{|s, i| s.preparePartConv(irbuffers[i], ~fftsize)}; // Create spectra from buffer channels
		s.sync;

		irbuffers.do(_.free); // applies free to all in array -- don't need time domain data anymore, just needed spectral version
	}.fork;

	s.sync;

	// 			SPECIFY DECODER

	//~decoder = FoaDecoderKernel.newSpherical;
	//~decoder = FoaDecoderMatrix.newQuad;
	//~decoder = FoaDecoderMatrix.newStereo;
	~decoder = FoaDecoderKernel.newUHJ;

	s.sync;


	// 			ADD REVERB MODULE DEFINITION

	SynthDef(\wrenchVerb, {|out, vol = 1, verb |
		var in = In.ar(~reverbSend, 4); // Input must be B-format

		verb = FoaDecode.ar(in,  FoaDecoderMatrix.newBtoA); // Decode
		verb = ~irspectra.collect{|s, i|
		PartConv.ar(verb[i], ~fftsize, s.bufnum, 0.3)*vol*0.1};
		verb = FoaEncode.ar(verb, FoaEncoderMatrix.newAtoB);  // Encode

		Out.ar(out, FoaDecode.ar(verb, ~decoder));
	}).add;

	s.sync;

	//			DEFINE SOME GROUPS

	~makeGroups = {|num|
		var l = List[];
		var g = Group.new;
		l.add(g);
		(num - 1).do {
			var gg = g;
			g = Group.after(gg);
			l.add(g);
		};
		l; // return the list
	};
	~groups = ~makeGroups.(8);

	// // SkipJack example
	SkipJack({ ~groups ?? { ~groups = ~makeGroups.(8) } }, 0.5);
	CmdPeriod.add({ ~groups = nil });
	// //   CmdPeriod.removeAll; // unregister all actions




	//			EFFECTS

	SynthDef(\wowEffect, {
		| buss = 0 |
		var sound;

		sound = DelayL.ar(In.ar(buss,2),0.2,SinOsc.kr(0.2, 0, 0.01,0.01));
		 SendPeakRMS.kr(sound*2, 20, 3, "/replyAddress");
		ReplaceOut.ar(buss,sound);
	}).add;


	SynthDef(\reson, { | freq = #[50,54,57,59,62] , pitches = 0, out = 0, in = 100 |
		var input, delay, dTime, pit, spela, ut;

		pit = (freq+pitches);
		dTime = (48000/pit.midicps);

		input = Mix.ar(In.ar(in))*0.25;

		spela = dTime.collect { | item, i |
			var sound = TwoTube.ar(input, 1,0.99 ,item/4, item/4);
			FoaPanB.ar(sound,LFSaw.ar(0.5*(i/5+0.1), mul: pi), LFSaw.ar(0.05*(i/5+0.1), mul: pi))}.sum;

		Out.ar(~reverbSend, spela*0.6);
		ut = FoaDecode.ar(spela, ~decoder);
		Out.ar(out, ut);
	}).add;


	SynthDef(\reson2, { | freq = 0 , pitches = 0, out = 0, pany = pi, gate = 1, datan =#[1,0], in = 100, fb = 0.5 |
		var input, delay, dTime, pit, spela, ut, sound, env, curve;

		env = Linen.kr(gate, 0.005, 1, 2.7, 2);
		curve = EnvGen.ar(Env.circle(LinLin.kr(datan,0.8,1.0,0,1),datan*10,[-5, 0, -5]));
		dTime = (48000/(freq+pitches));

		input = Mix.ar(In.ar(in))*0.25;
		input = HPF.ar(input,300);

		delay = TwoTube.ar(input, LinRand(1,-1),LinLin.kr(fb,0,1,0.95,0.99999) ,dTime/4, dTime/4)*env;
		delay = FoaPanB.ar(delay,Saw.ar(1/freq,pi/2));

		Out.ar(~reverbSend, delay*0.5);
		delay = FoaDecode.ar(delay, ~decoder);
		Out.ar(0,delay);
	}).add;


	SynthDef(\samplePlayer, { |
		out=0, buf = 0, 	rate = 1, at =0.01,
		rel= 0.1, pos =0, pSpeed = 0, lev = 0.5, datan =#[0,1,0]
		resSend = 1, revSend = 0.5, gate= 1, amp=1 |
		var sample, panT,  sound, curve, ampy;

		curve = EnvGen.kr(Env.circle(LinLin.kr(datan,0.9,1.0,0,1)*2,datan*at,[-5, 0, -5]));
		sample = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*curve, 1, 0, 1);
		panT= FSinOsc.kr(pSpeed);
		ampy = EnvGen.ar(Env.asr(at, amp, rel), gate, doneAction: 2);


		sound = Pan2.ar(sample, panT, ampy);
		Out.ar(~reverbSend, sound * revSend);
		Out.ar(~resonatorSend, (sound * resSend) * (curve/[1,10]));
		Out.ar(out, sound);
	}).add;


	s.sync;


	// MASTER OUTPUT

	SynthDef(\ambiOut, {|out= 0, dry = 1.0, wet = 0.0, in = 10 |
		var o = In.ar(~ambiBus, 4);

		o = FoaDecode.ar(o,~decoder);
		o = o * 1.5;
		Out.ar(out, o);
	}).add;

};
)

