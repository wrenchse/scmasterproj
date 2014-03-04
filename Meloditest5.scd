språng ned ej kvart - ters ok


(
//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//

//				//	-	-	-	-	-	-	-	-	-	-	//
//				//			 MELODY GENERATOR 9001			//
//				//			  A.K.A THE BACHINATOR			//
//				//			(c)JONTE KJELLBERGSSON			//
//				//	-	-	-	-	-	-	-	-	-	-	//


~melodyNotes = Prout({ | ev |
	var newNote, 	noteOut = 0, 	forceDown = 0, 	noDownJump = 0, 	up, 	down;

//	-	-	-	-	-	-	UP
	up = {
		noDownJump = 0;
		if(0.33.coin,
			{
				noteOut = noteOut+2+2.rand;
				forceDown = 100
			},{
				noteOut = noteOut+1;
			}
	)};

//	-	-	-	-	-	-	DOWN
	down = {
		forceDown = 0;
		if((noDownJump	+ 0.33).coin,
			{
				noteOut = noteOut-2;
				noDownJump = -100
			},{
				noteOut = noteOut-1
			}
	)};

//	-	-	-	-	-	-	-	-	-	PICK
	newNote = {
		if (LinLin.kr(forceDown + noteOut,-14, 14,1,0).coin,
			{
				up.value
			},{
				down.value
			}
	)};

	loop {
		ev = Pseq(Array.fill(100,{arg ev;
			newNote.value;
			ev = noteOut;
		})).embedInStream(ev);
	};

});

~melodyDur = { | i |
	var picker = 0,	 barR = 0, 		ev, newDur, 		durOut;

	newDur = 100.collect( {| i |
		durOut = switch (picker,
			0, { [1];	},
			1, { [1/2]; },
			2, { {1/3}.dup(3)				},
			3, { [1/4]						},
			4, { {1/6}.dup(3)				},
			5, { [1/8]						},
			6, { [2]						},
		);

		barR = barR + durOut.sum;
		barR = barR%1;

		picker = switch (barR.round(0.125),
			0.0, 		{ [0,1,2,3,4,5,6].wchoose([10,10,10,5,5,2,10].normalizeSum)	},
			0.5,		{ [1,3,4,5].wchoose([10,10,5,2].normalizeSum)				},
			0.25,		{ [3,5].choose												},
			0.75,		{ [3,5].choose												},
			0.125,		{ [5,3,1].wchoose([10,2,1].normalizeSum)					},
			0.875,      { 5 },
			0.625,      { [5,3].wchoose([10,1].normalizeSum)						},
			0.375,      { [5,3,1].wchoose([10,2,1].normalizeSum)					},
		);
		durOut;
	});
};

// ***************************************************************************** //
)


(
//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//


thisThread.randSeed = 0;

~melodi = 	Pbind(
	\instrument, 	\pinguPingu, 			//Pstutter(5,Pseq(.[\restrument,\default],inf)),
	\dur, 			Pseq(~melodyDur.value.flat),
	\degree, 		Pseed(100,~melodyNotes),
	\octave,		6,
	\amp,			0.2,
	\gate, 			1,
	\detune, [1,7,-5,-2,-4],
	\filtr,			Pwhite(1000,3000),
		\pan, 			Pwhite(-0.1,0.1,inf),
	*~pinguPresets.at(3),
);

~arp = 		Pbind(
	\instrument,	\pinguPingu,
	\degree,		Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
	\legato, 		1/4,
	\amp, 			0.4,
	\filtr,			Pwhite(300,1200),
	\dur, 			Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
	\octave,		4,
	\pan, 			Pwhite(-0.2,0.2,inf),
	*~pinguPresets.at(2),
);


~arp2 = 		Pbind(
	\instrument,	\pinguPingu,
	\degree,		Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
	\legato, 		1/1,
	\amp, 			0.5,
	\filtr,			Pwhite(200,1000),
	\dur, 			Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
	\octave,		7,
	\pan, 			Pwhite(-1,1,inf),
	*~pinguPresets.at(2),
);


~chords = Pbind(
	\instrument,	\pinguPingu,
	\degree,		[0, 2, 4, 7],
	\legato, 		3/4,
	\amp, 			0.2,
	\tempo, 		1,
	\filtr,			Pwhite(200,600),
	\pan, 			Pn([0.2,-0.2,-0.6,0.6].scramble,inf),
	\dur, 			Pseq([4],inf),
	\octave,		4,
	*~pinguPresets.at(1),
);

~bas = Pbind(
	\instrument,	\pinguPingu,
	\degree,		[0],
	\legato, 		1/2,
	\amp, 			0.6,
	\tempo, 		1,
	\filtr,			Pwhite(200,500),
	\pan, 			0,
	\dur, 			Pseq([4],inf),
	\octave,		2,
	*~pinguPresets.at(4),
);



~meta1 =	Pbind(
	\mtranspose,	Pswitch([0,-3,2,4],Ptime.new/4%4),
	\tempo,			1,
	\scale, 		[0, 2, 3, 5, 7, 9, 10],
	\stepsPerOctave,12
);

~spelaspela = Pchain(~meta1,	Ptpar([16, ~bas, 0, ~arp, 8, ~arp2, 16, ~chords, 16*2, ~melodi, 0, p, 0, ~resRoutine ])	)
)


Synth.new(\wrenchVerb, [\vol, 1]);

~spelaspela.play;


~spelaspela.stop;



// ***************************************************************************** //
(

~pinguPresets = Dictionary.new;
~pinguPresets.put(1, [	\envSynth,	[[2,0.1,0.9,5]],	\envFilter,	[[0.01,5,1,10]], \res,  1, \filter, 400, \revAmm, 0.5	 ]  ); // "1".asSymbol
~pinguPresets.put(2, [	\envSynth,	[[0.01,0.5,0.02,1]],	\envFilter,	[[0.01,0.1,0.4,1]], \res,  0.5, \saw0Pulse1, 0, \pulseWidth, 0.5	 ]  );
~pinguPresets.put(3, [	\envSynth,	[[0.01,2,0.2,1.1]],	\envFilter,	[[0.01,0.3,0.3,0.1]], \res,  1, \saw0Pulse1, 1, \pulseWidth, 0.05, \delDecay, 5, \revAmm, 0.5	 ]  );
~pinguPresets.put(4, [	\envSynth,	[[0.1,1.4,0.4,1.5]],	\envFilter,	[[0.1,2,0.2,1.5]], \res,  1]  );




//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//
//////////////////////////////////////////////////////////////////////////////////
//////////////////	-	-	-	-	-	-	-	-	-	-	//////////////////////
//////////////////			 SYN/TH/SKADAREN MK IV			//////////////////////
//////////////////			   A.K.A PINGU-PINGU			//////////////////////
//////////////////			(c)JONTE KJELLBERGSSON			//////////////////////
//////////////////	-	-	-	-	-	-	-	-	-	-	//////////////////////
//////////////////////////////////////////////////////////////////////////////////

SynthDef(\pinguPingu, { |
	gate		= 1,	freq		= 120,	filtr 		= 1000,
	res			= 1,	saw0Pulse1	= 0, 	pulseWidth	= 0.5,
	lfo1s		= 0.1,	lfo2s		= 0,	keyFollow	= 0,
	amp			= 1,	pan			= 0,	delDecay 	= 0.5,
	revAmm		= 0.1,

	/*	-	-	E	N	V	E	L	O	P	E	S	-	-	-	*/
	//				ATK		DCY		SUS		RLS
	envSynth 	= #[0.01,	0.1,	1,		1	],
	envFilter	= #[0.01,	0.2,	1,		4	]				|


	var syntEnv, filtEnv, sound, chorus, delay, waveForm, lfo1, lfo2;


	//lfo1 = SinOsc.kr(lfo1s,pi/2,0.5,1);
	//lfo2 = LFTri.kr(lfo2s);

//	-	-	-	-	-	-	-	-	-	CHOOSE WAVEFORM
	sound = Select.ar (saw0Pulse1,[
		Saw.ar	(		freq:	[freq,freq/2],	mul:	0.2),
		Pulse.ar(		freq:	[freq,freq/2],	mul:	0.2, 	width:	pulseWidth)
	]);

//	-	-	-	-	-	-	-	-	-	ENVELOPES
	syntEnv = EnvGen.ar(Env.adsr(*envSynth),	gate);
	filtEnv = EnvGen.kr(Env.adsr(*envFilter),	gate);

//	-	-	-	-	-	-	-	-	-	FILTER STAGE
	sound = Mix.ar(RLPF.ar(sound,
		freq:			filtr*filtEnv,
		rq:				res		)) ;


	sound =	Pan2.ar(sound,pan,1)* syntEnv;

//	-	-	-	-	-	-	-	-	-	CHORUS EFFECT
	chorus = (DelayL.ar(sound,
		maxdelaytime:	0.08,
		delaytime:		SinOsc.kr([0.2,0.4], 0, 0.005, [0.02,0.04]),
		mul: 			0.5));

//	-	-	-	-	-	-	-	-	-	DELAY EFFECT
	delay = CombC.ar(sound,
		maxdelaytime:	0.4,
		delaytime:		[0.2,0.4],
		decaytime:		delDecay,
		mul:			0.2);

	sound = sound + chorus + delay;

DetectSilence.ar(sound, doneAction:2);
//	-	-	-	-	-	-	-	-	-	OUTPUT MODULE
	Out.ar(~reverbSend,sound * revAmm/2);
	Out.ar(0,
		(	sound 	) * amp);



}).add;

// ***************************************************************************** //
)



MIDIIn.connectAll;

(
MIDIFunc.noteOn({arg vel, note; y = Synth(\pinguPingu, [
	\freq, note.midicps,\lfo1s,1	]
	++ ~pinguPresets.at(1)
).postln });

MIDIFunc.noteOff({arg vel, note; y.set(\gate, 0).postln });
)




w = Synth.new(\wowEffect);
w.free;










































t.do{ arg item, i; t.at(i)}.flatten(0);

t = [	\envSynth,	[0,0.1,0.5,10],	\envFilter,	[0.01,5,1,10] ]
t.at(0)
t






( // ARPEGGIO
a = Pmono(\synthBygge,
	\degree,	Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
//	\strum,		Prand([1/6], inf),
	\legato, 	1/2,
	\amp, 0.6,
	\tempo, 1,
	\filtr,    Pwhite(200,2000,inf),
	\dur, 		Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
	\octave,	5,
	\gate, 1,
	\scale, 	[0, 2, 3, 5, 7, 9, 10],
	\stepsPerOctave, 12,
	\mtranspose,Pgate(Pseq([0,-2,3,4],inf),inf,\step),
	*~pinguPresets.at(4)
).play;


)








z = ~melodyDur;
z.do(_.postln);""
z.next

f = {|i|
	var dur;
	var lo = 0.1, hi = 2.0;
	var out = rrand(lo,hi);
	if (i == 0) {
		out = { 1/3 }.dup(3);
	};
	out;
};

f.asStream

x = 10.collect {|i| f.value(i % 5) }

x.flat.do(_.postln);


""

10.flat
z.free
z.do(_.postln);""
x = x.flat



~durSeq = Pseq(x);
thisThread.randSeed = 100;









 4.collect{1/4} ++ 8.collect{1/8}
a.stop



a= Pbind(\instrument, \synthBygge, \freq, Pseq([[100, 200, 300], [160,
240, 320]], inf), \strum, Prand([0.1, 0.2], inf), \legato, 0.65, \dur,
0.5,
	*~pinguPresets.at(2)).play
a.stop






Scale.directory
Tuning.directory

DegreeToKey





(
SynthDef(\sinLead, { | gate = 1, freq = 50 |
    var mix, env;

	env = EnvGen.ar(Env.adsr(0.08, 0.02, 0.01, 1.0,0.5,-4),gate,doneAction:2);

	mix = SinOsc.ar([freq,freq] + LFNoise1.kr([3.rand,4.rand],1),mul: 0.3);
    // add some 70's euro-space-rock echo

	mix = CombN.ar(mix, 0.31, 0.31.rand, 0.2, 0.4, mix)*env;

	Out.ar(0,mix);
}).add;
)































(
~melodyDur = { | i |
	var picker = 0,	 barR = 0, 		ev, newDur, 		durOut;

	newDur = 100.collect( {| i |
		durOut = switch (picker,
			0, { [1];	},
			1, { [1/2]; },
			2, { {1/3}.dup(3)				},
			3, { [1/4]						},
			4, { {1/6}.dup(3)				},
			5, { [1/8]						},
			6, { [2]						},
		);

		barR = barR + durOut.sum;
		barR = barR%1;

		picker = switch (barR.round(0.125),
			0.0, 		{ [0,1,2,3,4,5,6].wchoose([10,10,10,5,5,2,10].normalizeSum)	},
			0.5,		{ [1,3,4,5].wchoose([10,10,5,2].normalizeSum)				},
			0.25,		{ [3,5].choose												},
			0.75,		{ [3,5].choose												},
			0.125,		{ [5,3,1].wchoose([10,2,1].normalizeSum)					},
			0.875,      { 5 },
			0.625,      { [5,3].wchoose([10,1].normalizeSum)						},
			0.375,      { [5,3,1].wchoose([10,2,1].normalizeSum)					},
		);
		durOut;
	});
};
)

~melodyDirur.value.flat

~melodyDur.value.flat.do(_.postln);
