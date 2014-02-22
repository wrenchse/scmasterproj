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
//  W A V E F O R M S --------------------------------------------------- //

(
SynthDef(\sine, { | amp = 0.1, freq = 440, out = 11 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = SinOsc.ar(freq,0)*0.1*swell;
	Out.ar(out,wave);
}, [0.5, 0.5]).add;


SynthDef(\saw, { | amp = 0.1, freq = 440, out = 11 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Saw.ar(freq)*0.1*swell;
	Out.ar(out,wave*0.2);
}, [0.5, 0.5]).add;


SynthDef(\Tri, { | amp = 0.1, freq = 440, width = 0.1, out = 11 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = LFTri.ar(freq)*0.1*swell;
	Out.ar(out,wave*0.5);
}, [0.5, 0.5]).add;


SynthDef(\pulse, { | amp = 0.1, freq = 440, width = 0.1, out = 11 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Pulse.ar(freq, width)*0.1*swell;
	Out.ar(out,wave*0.2);
}, [0.5, 0.5, 0.5]).add;

SynthDef(\nojs, { | amp = 0.1, freq = 20000, width = 0.1, out = 11, vol = 0.0 |
	var wave, swell;
	swell = LFDNoise3.ar(amp);
	wave = Dust.ar(freq, 1)*0.1*swell*vol;
	Out.ar(out,wave*0.5);
}, [0.5, 0.5, 0.5]).add;


);

//  M O D U L E S ------------------------------------------------------ //

(
SynthDef(\mixer, { | avol = 1.0, bvol = 1.0, hpa = 0, hpb = 0, mix = -1 |
	var layerA, layerB, nojs, modul;

	layerA = HPF.ar(In.ar(11,1)*avol,hpa);
	layerB = HPF.ar(In.ar(12,1)*bvol,hpb);
	nojs = In.ar(17);

	modul = XFade2.ar(layerB+layerA,(layerB*layerA)*20,mix);

	Out.ar(30,modul+nojs);

	/*Out.ar(0,layerA);
	Out.ar(1,layerB);*/
}).add;
);


(
SynthDef(\reverb, { | mix = 0, prepost |

	var z, y, s;


	s = In.ar(30);

	// reverb predelay time :
	z = DelayN.ar(s, 0.048);

	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));

	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });

	// add original sound to reverb and play it :
	Out.ar(32,(s+(mix*(y*0.5)))*0.5);
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
	Out.ar([~ambiBus],[delay1, delay2]);


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
	Out.ar([~ambiBus],[delay*0.2,delay*0.2]);

},[0.5,2]).add;
);

)








PG_Cookbook07_Rhythmic_Variations
An ever-changing drumbeat

Pitch












// ---------------------------------------------------------------------------------

(

u = { | freqs =#[47,48,49,50], pitches = 20, amm |

	var in, out, delay, dTime;

	dTime = (1000/(freqs).midicps)/1000;

	in = (PinkNoise.ar(0.1)+Saw.ar(1500,0.2)) * EnvGen.ar(Env.perc(0.05, 0.01, 0.01, -4),Impulse.kr(1)); // + LocalIn.ar(1);

	delay = CombC.ar(in, 0.2, dTime, 15, 5);
	//LocalOut.ar(LeakDC.ar(delay*0.8));
	Out.ar([0,1],delay);

}.play;
);


60.midicps

1000/12

1000/83.33333








Document.open("/Synth 2.sc")











