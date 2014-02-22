s.options.memSize

(
//  B O O T --------------------------------------------------------------------- //

~fftsize=2048;
~reverbSend 	= Bus.audio(s, 4);
~resonatorSend	= Bus.audio(s, 4);

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

		ReplaceOut.ar(buss,sound);
	}).add;


	SynthDef(\reson, { | freq = #[50,54,57,59,62] , pitches = 0, out = 0 |
		var in, delay, dTime, pit, spela, ut;

		pit = (freq+pitches);
		dTime = (48000/pit.midicps);

		in = Mix.ar(In.ar(~resonatorSend))*0.25;

		spela = dTime.collect { | item, i |
			var sound = TwoTube.ar(in, 1,0.99 ,item/4, item/4);
			FoaPanB.ar(sound,LFSaw.ar(0.5*(i/5+0.1), mul: pi), LFSaw.ar(0.05*(i/5+0.1), mul: pi))}.sum;

		Out.ar(~reverbSend, spela*0.6);
		ut = FoaDecode.ar(spela, ~decoder);
		Out.ar(out, ut);
	}).add;


	SynthDef(\reson2, { | freq = 0 , pitches = 0, out = 0, pany = pi, gate = 1 |
		var in, delay, dTime, pit, spela, ut, sound, env;

		env = Linen.kr(gate, 0.005, 1, 2.7, 2);
		dTime = (48000/(freq+pitches));

		in = Mix.ar(In.ar(~resonatorSend))*0.25;

		delay = TwoTube.ar(in, LinRand(1,-1),0.9995 ,dTime/4, dTime/4)*env;
		delay = FoaPanB.ar(delay,pany);

		Out.ar(~reverbSend, delay*0.5);
		delay = FoaDecode.ar(delay, ~decoder);
		Out.ar(0,delay);
	}).add;
};


)



