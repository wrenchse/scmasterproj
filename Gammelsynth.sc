(
//  B O O T --------------------------------------------------------------------- //

~fftsize=2048;

s.waitForBoot{

	s.options.sampleRate= 48000;

	//b = Buffer.readChannel(s, "Hall1.wav".resolveRelative, channels: [0]);
	{
		var ir, irbuffers = Array.fill(4), bufsize;
		irbuffers.do {|b, i| irbuffers[i] = Buffer.readChannel(s, "Hall1.wav".resolveRelative, channels: [i], numFrames: 48000*2)};

		s.sync;
		bufsize= PartConv.calcBufSize(~fftsize, irbuffers[0]).postln;

		// ~numpartitions= PartConv.calcNumPartitions(~fftsize, irbuffer);

		//~irspectrum= Buffer.alloc(s, bufsize, 1);
		~irspectra= Array.fill(4,{Buffer.alloc(s, bufsize, 1)});

		// ~irspectrum.preparePartConv(irbuffer, ~fftsize);
		~irspectra.do{|s, i| s.preparePartConv(irbuffers[i], ~fftsize)};

		s.sync;

		irbuffers.do(_.free); // applies free to all in array    don't need time domain data anymore, just needed spectral version
	}.fork;

};


)


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
	// o = FoaTransform.ar(o, 'rotate', LFSaw.ar(1/2,0,pi));

	// Convolution Reverb
	o = FoaDecode.ar(o,  FoaDecoderMatrix.newBtoA);
	//	o = (o*dry) + (PartConv.ar(o, ~fftsize, ~irspectrum.bufnum, 0.5)*wet);
	o = (o*dry) + ~irspectra.collect{|s, i| PartConv.ar(o[i], ~fftsize, s.bufnum, 0.3)*wet*0.1};
	o = FoaEncode.ar(o, FoaEncoderMatrix.newAtoB);

	Out.ar(out, FoaDecode.ar(o, ~decoder));
}).add;
)



(

~layerAroute = Bus.audio(s,1);
~layerBroute = Bus.audio(s,1);


//  W A V E F O R M S --------------------------------------------------- //

(
SynthDef(\sine, { | amp = 0.1, freq = 440, out = 0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = SinOsc.ar(freq,0)*0.1*swell;
	Out.ar(out,wave);
}, [0.5, 0.5]).add;


SynthDef(\saw, { | amp = 0.1, freq = 440, out = 0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Saw.ar(freq)*0.1*swell;
	Out.ar(out,wave*0.2);
}, [0.5, 0.5]).add;


SynthDef(\Tri, { | amp = 0.1, freq = 440, width = 0.1, out = 0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = LFTri.ar(freq)*0.1*swell;
	Out.ar(out,wave*0.5);
}, [0.5, 0.5]).add;


SynthDef(\pulse, { | amp = 0.1, freq = 440, width = 0.1, out = 0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Pulse.ar(freq, width)*0.1*swell;
	Out.ar(out,wave*0.2);
}, [0.5, 0.5, 0.5]).add;

SynthDef(\nojs, { | amp = 0.1, freq = 20000, width = 0.1, out = 0, vol = 0.0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Dust.ar(freq, 1)*0.1*swell*vol;
	Out.ar(out,wave*0.5);
}, [0.5, 0.5, 0.5]).add;


);

//  M O D U L E S ------------------------------------------------------ //

(
SynthDef(\mixer, {|
	del1 = 0.003, 		del2 = 0, out = 0, 	avol = 1.0,		bvol = 1.0, 	hpa = 0,
	hpb = 0, 	mix = -1,
	fbf = 0.01,	resSend = 0,	dstAmm = 1, 	dstFreq = 5000 |

	var layerA, layerB, modul, feedback, local;

	//		LAYERS CROSS FADE AND CROSS MODULATION

	layerA = 	HPF.ar(In.ar(~layerAroute,1)*avol,hpa);
	layerB = 	HPF.ar(In.ar(~layerBroute,1)*bvol,hpb);
	modul = 	XFade2.ar(layerB+layerA,(layerB*layerA)*20,mix);


	//		PHASE SPIN EFFECT (PAN)

	local = 	LocalIn.ar(1);
	feedback = 	SinOsc.ar(fbf);
	modul =		modul + (local*fbf);
	modul =		[DelayC.ar(modul,0.2,del1*SinOsc.kr(0.1,add:1)), DelayC.ar(modul,0.2,del2)];
	LocalOut.ar(LeakDC.ar(modul[0]));
	modul = 	DFM1.ar(modul,dstFreq,0.1,dstAmm)/(1+(dstAmm/3));

	Out.ar(out, modul);
},[1,1,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]).add;
);


(
SynthDef(\smear, { | mix = 1, in = 30 |
	var sound;

	sound = In.ar(in);

	sound = DelayN.ar(sound, 0.048);	// reverb predelay time

	sound = Mix.ar(Array.fill(7,{ CombL.ar(sound, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) })); 	// 7 length modulated comb delays in parallel :

	sound = 4.collect({ AllpassN.ar(sound, 0.050, [0.050.rand, 0.050.rand], 1) }); // two parallel chains of 4 allpass delays (8 total) :

	Out.ar(0,sound*0.5);
}).add;
);


(
SynthDef(\panspin, { | del1 = 0, del2 = 0, fbf = 0.01, resSend = 0, dstAmm = 1, dstFreq = 5000 |

	var in, o, in2, filter, fb, delay1 = 0, delay2, local;

	local = LocalIn.ar(2);
	fb = SinOsc.ar(fbf);
	in = In.ar(32) + (local*fbf);
	delay1 = DelayC.ar(in,0.2,del1);
	delay2 = DelayC.ar(in,0.2,del2);

	LocalOut.ar(LeakDC.ar(delay1));

	delay1 = DFM1.ar(delay1,dstFreq,0.1,dstAmm)/(1+(dstAmm/3));
	delay2 = DFM1.ar(delay2,dstFreq,0.1,dstAmm)/(1+(dstAmm/3));

	//Out.ar([50,51],[delay1, delay2]*resSend);
	//Out.ar([~ambiBus],[delay1, delay2]);


},[0.5, 0.5, 0.5]).add;
);

(
SynthDef(\resonator, { | freqs =#[40,44,47,52,56] , pitches = 0, fb = 0, vol = 0.0 |

	var in, out, delay, dTime, pit;

	pit = freqs+pitches;
	dTime = (1000/(freqs+pitches).midicps)/1000;

	in = HPF.ar(In.ar(30,1),100);

	delay = CombC.ar(in, 0.2, dTime, fb, 10)*vol;
	//LocalOut.ar(LeakDC.ar(delay*0.8));
	//Out.ar([~ambiBus],[delay*0.2,delay*0.2]);

},[0.5,2]).add;
);

)


(
f = Pmono(
	\mixer,
	\del1, Pseq([0.001,0.02,0.003,0.0004],inf),
	\mix, 0.5,
	\distAmm, 20,
);
t = Ppar(
	4.collect { | i |
	Pn(Pmono(
		[\sine, \saw, \Tri, \pulse].at(i),
		\amp, 0.2,
		\dur, 1,
		\out, ~layerAroute,
		\degree, [0,15,27,33],
		\resSend, 0.5,
		\octave, 1,
	),inf);
	} ++
	4.collect { | i |
	Pn(Pmono(
		[\sine, \saw, \Tri, \pulse].at(i),
		\amp, 0.2,
		\dur, 1,
		\out, ~layerBroute,
		\degree, [0,15,27,33],
		\resSend, 0.5,
		\octave, 3,
	),inf);
	}
);
)

(
f.play;
t.play
)