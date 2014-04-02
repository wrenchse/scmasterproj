// AMBISONICS --------------------------------------------------------------------- //
(
~decoder = FoaDecoderKernel.newSpherical;
//~decoder = FoaDecoderMatrix.newQuad;
//~decoder = FoaDecoderMatrix.newStereo;
//~decoder = FoaDecoderKernel.newUHJ;

~ambiBus = Bus.audio(s, 2);
)
(
SynthDef(\ambiOut, {|out, dry = 1.0, wet = 0.0 |
	var in = In.ar(~ambiBus, 2);

	o = FoaEncode.ar(in, FoaEncoderMatrix.newStereo);

	// image (spatial filtering)
	 o = FoaTransform.ar(o, 'rotate', LFSaw.ar(1/2,0,pi));

	// Convolution Reverb
//	o = FoaDecode.ar(o,  FoaDecoderMatrix.newBtoA);
//	o = (o*dry) + (PartConv.ar(o, ~fftsize, ~irspectrum.bufnum, 0.5)*wet);
//	o = (o*dry) + ~irspectra.collect{|s, i| PartConv.ar(o[i], ~fftsize, s.bufnum, 0.5)*wet*0.1};
//	o = FoaEncode.ar(o, FoaEncoderMatrix.newAtoB);

	Out.ar(in, FoaDecode.ar(o, ~decoder));
}).load(s);
)