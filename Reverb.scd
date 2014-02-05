(
//  B O O T --------------------------------------------------------------------- //

~fftsize=2048;
~reverbSend = Bus.audio(s, 10);

s.waitForBoot{
	s.options.sampleRate= 48000;
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


	// ADD REVERB MODULE DEFINITION

	SynthDef(\wrenchVerb, {|out, vol = 1, verb |
		var in = In.ar(~reverbSend, 4); // Input must be B-format

		verb = FoaDecode.ar(in,  FoaDecoderMatrix.newBtoA); // Decode
		verb = ~irspectra.collect{|s, i|
			PartConv.ar(verb[i], ~fftsize, s.bufnum, 0.3)*vol*0.1};
		verb = FoaEncode.ar(verb, FoaEncoderMatrix.newAtoB);  // Encode

		Out.ar(out, FoaDecode.ar(verb, ~decoder));
	}).add;


	// SPECIFY DECODER

	~decoder = FoaDecoderKernel.newSpherical;
	//~decoder = FoaDecoderMatrix.newQuad;
	//~decoder = FoaDecoderMatrix.newStereo;
	//~decoder = FoaDecoderKernel.newUHJ;

};
)




Synth.new(\wrenchVerb)


