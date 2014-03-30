s.options.memSize

(
//  B O O T --------------------------------------------------------------------- //

~fftsize=2048;
~reverbSend 	= Bus.audio(s, 4);
~resonatorSend	= Bus.audio(s, 4);

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

		delay = TwoTube.ar(input, LinRand(1,-1),LinLin.kr(fb,0,1,0.95,0.99999) ,dTime/4, dTime/4)*env;
		delay = FoaPanB.ar(delay,pany);

		Out.ar(~reverbSend, delay*0.5);
		delay = FoaDecode.ar(delay, ~decoder);
		Out.ar(0,delay);
	}).add;

	SynthDef(\samplePlayer, { |
		out=0, buf = 0, 	rate = 1, at =0.01,
		rel= 0.1, pos =0, pSpeed = 0, lev = 0.5, datan =#[0,1,0]
		resSend = 1, revSend = 0.5, gate= 1 |
		var sample, panT,  amp, sound, curve;

		curve = EnvGen.kr(Env.circle(LinLin.kr(datan,0.9,1.0,0,1)*2,datan*at,[-5, 0, -5]));
		sample = PlayBuf.ar(4, buf, BufRateScale.kr(buf)*curve, 1, 0, 1);
		panT= FSinOsc.kr(pSpeed);
		amp = EnvGen.ar(Env.asr(at, 1, rel), gate, doneAction: 2);


		sound = Pan2.ar(sample, panT, amp);
		Out.ar(~reverbSend, sound * revSend);
		Out.ar(~resonatorSend, (sound * resSend) * (curve/[1,10]));
		Out.ar(out, sound);
	}).add;

	// MASTER OUTPUT

	SynthDef(\ambiOut, {|out, dry = 1.0, wet = 0.0, in = 10 |
		var o = In.ar(in, 2);

		Out.ar(out, FoaDecode.ar(o, ~decoder));
	}).add;
};
)


Array



//
// m = NetAddr("127.0.0.1", 9000); // loopback
//
// m.sendMsg("/chat", "Hello App 1");
//
//
//
// (
// {
// 	SendPeakRMS.kr(Dust.ar(1), 20, 3, "/replyAddress")
// }.play;
// )
//
// (
// m = NetAddr("127.0.0.1", 9000); // loopback
// o = OSCFunc({ |msg| m.sendMsg("/rms", msg[3]*2)}, '/replyAddress');
// )
// o.free;
o.free;
//
(

o = OSCFunc({| msg |
	Synth(\snare);
		~data = msg;
	~data.removeAt(0);
	~pMetafyx.(data: ~data, vol: 0.4, mix: -1, len: 1,  smear: 0.2, lpf: 10000, resS: 1, dist: 2, dmix: -1 ).play;
}, '/start'); // create the OSCresponderNode

p = OSCFunc({| msg |
	Synth(\kick);
}, '/gui'); // create the OSCresponderNode

)
~data
	~pMetafyx.(data: ~data, vol: 0.4, mix: -1, len: 1,  smear: 0.2, lpf: 10000, resS: 1, dist: 2, dmix: -1 ).play;
//
// Synth(\kick);
//
//
// NetAddr.localAddr.port
//
// OscFunc
//
//
// SendPeakRMS
//
