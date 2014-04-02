
//  W A V E F O R M S --------------------------------------------------- //

(
SynthDef(\sine, { | amp = 0.1, freq = 440, out = 0, cykel = 1 |
	var wave, swell, trigger, env, envctl;
	trigger = Trig.kr(Impulse.kr(10),cykel);

	env = Env.newClear(16);
	envctl = \env.kr(env.asArray);

	swell = EnvGen.kr(envctl, trigger);
	wave = SinOsc.ar(freq, mul: amp*0.1)*swell;
	Out.ar(out,wave);
}, [0.5, 0.5]).add;


SynthDef(\saw, { | amp = 0.1, freq = 440, out = 0, cykel = 1 |
	var wave, swell, trigger, env, envctl;
	trigger = Trig.kr(Impulse.kr(10),cykel);

	env = Env.newClear(16);
	envctl = \env.kr(env.asArray);

	swell = EnvGen.kr(envctl, trigger);
	wave = Saw.ar(freq, mul: amp*0.05)*swell;
	Out.ar(out,wave);
}, [0.5, 0.5]).add;

SynthDef(\Tri, { | amp = 0.1, freq = 440, out = 0, cykel = 1 |
	var wave, swell, trigger, env, envctl;
	trigger = Trig.kr(Impulse.kr(10),cykel);

	env = Env.newClear(16);
	envctl = \env.kr(env.asArray);

	swell = EnvGen.kr(envctl, trigger);
	wave = LFTri.ar(freq, mul: amp*0.1)*swell;
	Out.ar(out,wave);
}, [0.5, 0.5]).add;


SynthDef(\pulse, { | amp = 0.1, freq = 440, width = 0.1, out = 0, cykel = 1 |
	var wave, swell, trigger, env, envctl;
	trigger = Trig.kr(Impulse.kr(10),cykel);

	env = Env.newClear(16);
	envctl = \env.kr(env.asArray);

	swell = EnvGen.kr(envctl, trigger);
	wave = Pulse.ar(freq, width)*0.1*swell;
	Out.ar(out,wave*0.2*amp);
}, [0.5, 0.5, 0.5]).add;


SynthDef(\nojs, { | amp = 0.1, freq = 20000, width = 0.1, out = 0, cykel = 1 |
	var wave, swell, trigger, env, envctl;
	trigger = Trig.kr(Impulse.kr(10),cykel);

	env = Env.newClear(16);
	envctl = \env.kr(env.asArray);

	swell = EnvGen.kr(envctl, trigger);
	wave = Dust.ar(freq, mul: amp*0.1)*swell;
	Out.ar(out,wave);
}, [0.5, 0.5, 0.5]).add;


//  M O D U L E S ------------------------------------------------------ //


SynthDef(\mixer, {|
	del1 = 0.003, 	del2 = 0,	out = 0, 	avol = 1.0,		bvol = 1.0, 	lpa = 0,
	lpb = 0, 		mix = -1,	fbf = 0.01,	resSend = 1,	dstAmm = 1, 	dstFreq = 5000,
	layA = 20, 		layB = 21,	res = 100,	smear = 0.1, 	amp = 1,		dstRes  = 1,
	dstMix = -1, 	da	= 2,	env = #[1,1,1,1],			gate = 1				|

	var layerA, layerB, modul, feedback, local, sound, envelope;

	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: da);

	//		LAYERS CROSS FADE AND CROSS MODULATION

	layerA = 	LPF.ar(In.ar(layA,1)*avol,lpa);
	layerB = 	LPF.ar(In.ar(layB,1)*bvol,lpb);
	modul = 	XFade2.ar(layerB+layerA,(layerB*layerA)*20,mix)*amp;


	//		PHASE SPIN EFFECT (PAN)

	local = 	LocalIn.ar(1);
	feedback = 	SinOsc.ar(fbf);
	modul =		modul + (local*fbf);
	modul =		[DelayC.ar(modul,0.2,del1*SinOsc.kr(0.1,add:1)), DelayC.ar(modul,0.2,del2)];
	LocalOut.ar(LeakDC.ar(modul[0]));
	modul = 	LinXFade2.ar(modul, DFM1.ar(modul,dstFreq,dstRes,dstAmm)/(2+(dstAmm/4)), dstMix);

	//		SMEAR EFFECT

	sound = DelayN.ar(modul, 0.048);	// reverb predelay time
	sound = Mix.ar(Array.fill(7,{ CombL.ar(sound, 0.1, LFNoise1.kr(0.01.rand, 0.04, 0.05), 15) })); 	// 7 length modulated comb delays in parallel
	sound = 2.collect({ AllpassN.ar(sound, 0.050, [0.050.rand, 0.050.rand], 1) }); // two parallel chains of 4 allpass delays (8 total) :

	Out.ar(res, Mix.ar(modul*resSend));
	Out.ar(out, modul+(sound*smear));
},[0.5]).add;



~pMetafyx = { |
	mix = -1, 		dist = 1, 		spin = #[0.002],	data = #[1,1,1,1,1,1,1],
	len = 5, 		smear = 0,		vol = 1, 			lpf = 500,
	resS = 0.2,		out = 0,		res = 100,			dfrq = 500
	dmix = -1,		grp = 1														|

	var layA = 40, layB = 41, curves = Array.fill(10), curlen = Array.fill(10), metaNotes = Array.fill(7);


	// CREATE ENVELOPES
	7.do { |i|
		var thing = data.rotate(i).slide(i+1,1);
		curves[i] =	Env(LinLin.kr(thing, data.minItem, data.maxItem, 0.0, 1.0),(10/thing.size)*len);
		curlen[i] = thing.collect { 10/thing.size }.sum -1;
	};


	// PICK NOTES

	metaNotes = 6.collect {|i|	LinLin.kr(data[i],data.sum/7,1.0,0,24).round  };

	m = Pchain(			// Parent-variabler
		Pbind(
			 \group, ~groups[0],
		),
		Ppar([
			Pmono(								// MIXER EVENT
				\mixer,
				\del1, Pseq(spin,inf),
				\mix, mix,
				\dstAmm, dist,
				\dstFreq, dfrq,
				\dstMix, dmix,
				\addAction, 1,
				\layA, layA,
				\layB, layB,
				\smear, smear/10,
				\amp, 0.5*vol,
				\lpa, lpf,
				\lpb, lpf,
				\res, res,
				\resSend, resS,
				\out, out,
				\da, 13,
			)
			] ++ [
				Ppar(
					3.collect { | i |			// LAYER A OSCILLATORS
						Pmono(
							[\sine, \Tri].at(i%2),
							\amp, 0.5,
							\out, layA,
							\degree, metaNotes[i],
							\octave, 3,
							\scale, ~scaleBuilder.(data),
							\env, [curves[i]],
							\cykel, curlen[i]*len,
							\root, ~root.(data),
						);
					} ++

					3.collect { | i |			// LAYER B OSCILLATORS
						Pmono(
							[\sine, \Tri].at(i%2),
							\amp, 0.5,
							\out, layB,
							\degree, metaNotes[i+3],
							\octave, 3,
							\scale, ~scaleBuilder.(data),
							\env, [curves[i+3]],
							\cykel, curlen[i+3]*len,
							\root, ~root.(data),
						);
					} ++
					2.collect { | i |			// PULSES, Rhytmic
						Pmono(
							\pulse,
							\out, layA+i,
							\octave, -3,
							\degree, i*10,
							\amp, 0.9,
							\env, [curves[i+5]],
							\cykel, curlen[i+5]*len,
						)
					} ++
					2.collect { | i |
						Pmono(
							\nojs,
							\out, layA+i,
							\amp, 0.5,
							\env, [curves[i+5]],
							\cykel, curlen[i+5]*len,
						)
					}
				)
			] ++ [
				Pmono(
					\reson2,
					\in, res,
					\addAction, 1,
					\degree, [0,2,4,7,8],
					\fb, 0.9,
					\scale, ~scaleBuilder.(data),
					\root, ~root.(data),
				)
			]
		)
	);
};

);









/*

(
~data = 7.collect( { 1-0.2.rand } );
p = ~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 10,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1).play;
//~chords.(~data, \pinguPingu, 3).play;
//~arp.(~data, \pinguPingu, 4).play
)



p.stop

s.plotTree







(
~phrases = (
	    repeated: Pbind(
		       \mtranspose, 1,
		\dur, Pseq([1],1),
	    ),
	    octave: Pbind(
		       \mtranspose, 2,
		\dur, Pseq([1],1),
	    ),
	    tritone: Pbind(
		        \mtranspose, 3,
		\dur, Pseq([1],1),
	    ),
	    dim: Pbind(
		        \mtranspose, -5,
		\dur, Pseq([1],1),
	    )
);




TempoClock.default.tempo = 128/60;

// the higher level control pattern is really simple now
p = Pchain(
	Psym(\meta2,~dict)
	, Psym(Pxrand(#[repeated, octave, tritone, dim], inf), ~phrases)).play;
)
p.stop



(
~dict = (
	meta:
	~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 1,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1 ) ,
	meta2:
	~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 1,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1 )
);

)





g = [~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 1,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1 ),~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 1,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1 )]

p[1]




~dict = (
	meta:
	~arp.(6)
);

~phrases = (
	repeated: Pbind(
		\mtranspose, 1,
		\dur, Pseq([1],1),
	),
	octave: Pbind(
		\mtranspose, 2,
		\dur, Pseq([1],1),
	),
	tritone: Pbind(
		\mtranspose, 3,
		\dur, Pseq([1],1),
	),
	dim: Pbind(
		\mtranspose, -5,
		\dur, Pseq([1],1),
	)
);

TempoClock.default.tempo = 128/60;

// the higher level control pattern is really simple now
p = Pchain(
	p[1],
	Psym(Pxrand(#[repeated, octave, tritone, dim], inf), ~phrases)).play;

)


p.stop



Psym(\meta,~dict)












~arp = { | oct |
	Pbind(
		\degree,		Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
		\legato, 		1/4,
		\amp, 			0.4,
		\filtr,			Pwhite(300,1200),
		\dur, 			Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
		\octave,		oct,
		\pan, 			Pwhite(-0.2,0.2,inf),
	)
};





~chords = { | data, inst, oct |

	Pbind(
		\instrument,	inst,
		\degree,		[0, 2, 4, 7],
		\legato, 		3/4,
		\amp, 			0.2,
		\tempo, 		1,
		\filtr,			Pwhite(200,600),
		\pan, 			Pn([0.2,-0.2,-0.6,0.6].scramble,inf),
		\dur, 			Pseq([4],inf),
		\octave,		oct,
		\scale, 		~scaleBuilder.(data),//[0, 2, 3, 5, 7, 9, 10],
		\root,          ~root.(data),
		*~pinguPresets.at(1),
	);
}

*/