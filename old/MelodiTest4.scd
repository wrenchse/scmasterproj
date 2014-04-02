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
		ev = Pseq(Array.fill(1,{arg ev;
			newNote.value;
			ev = noteOut;
		})).embedInStream(ev);
	};

});

~melodyDur = Prout({ | ev |
	var picker = 0,	 barR = 0, 		newDur, 		durOut;

	newDur = {
		durOut = switch (picker.post,
			0, { [1];	},
			1, { [1/2]; },
			2, { {1/3}.dup(3);				},
			3, { [1/4]						},
			4, { {1/6}.dup(3);				},
			5, { [1/8]						},
			6, { [2]						},
		);

		barR = barR + durOut.sum;
		barR = barR%1;

		picker = switch (barR.round(0.125).postln,
			0.0, 		{ [0,1,2,3,4,5,6].wchoose([10,10,10,5,5,2,10].normalizeSum)	},
			0.5,		{ [1,3,4,5].wchoose([10,10,5,2].normalizeSum)				},
			0.25,		{ [3,5].choose												},
			0.75,		{ [3,5].choose												},
			0.125,		{ [5,3,1].wchoose([10,2,1].normalizeSum)					},
			0.875,      { 5 },
			0.625,      { [5,3].wchoose([10,1].normalizeSum)						},
			0.375,      { [5,3,1].wchoose([10,2,1].normalizeSum)					},
		);
	};

	loop {  				// FRÅGA DAVID HUR MAN KAN FÅ DEN ATT GENERERA PRECIS SOM MELODITONERNA
		newDur.value;
		ev = Pseq(durOut).embedInStream(ev);
	};
});
// ***************************************************************************** //
)



(
//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//
Pbind(*[
	instrument: 	\synthBygge, 			//Pstutter(5,Pseq(.[\restrument,\default],inf)),
	dur: 			Pseed(101,~melodyDur),
	degree: 		Pseed(100,~melodyNotes),
	scale:			[0, 2, 3, 5, 7, 9, 10],
	stepsPerOctave: 20,
	mtranspose: 	0,
	tempo:			1,
	filter:			Phprand(100,2000,inf),
	saw0Pulse1:		0,//Pbeta(0.0,1.0,length:inf),
]).play

// ***************************************************************************** //
)




(
//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//

//				//	-	-	-	-	-	-	-	-	-	-	//
//				//			 SYN/TH/SKADAREN MK IV			//
//				//			   A.K.A PINGU-PINGU			//
//				//			(c)JONTE KJELLBERGSSON			//
//				//	-	-	-	-	-	-	-	-	-	-	//

SynthDef(\synthBygge, { |
	gate		= 1,	freq		= 120,	filter 		= 1000,
	resonance	= 0.2,	saw0Pulse1	= 0, 	pulseWidth	= 0.5,
	lfo1		= 0,	lfo2		= 0,	keyFollow	= 0		|

	var syntEnv, filtEnv, sound, chorus, delay, waveForm;

//	-	-	-	-	-	-	-	-	-	CHOOSE WAVEFORM
	sound = XFade2.ar (
		Saw.ar	(		freq:	[freq,freq/2],	mul:	0.2),
		Pulse.ar(		freq:	[freq,freq/2],	mul:	0.2, 	width:	pulseWidth),
		LinLin.kr(		saw0Pulse1,0,1,-1,1);
	);

//	-	-	-	-	-	-	-	-	-	SYNTH ENVELOPE
	syntEnv = EnvGen.ar(Env.adsr(
		0.009,	//		A
		0.2,	//		D
		0.3, 	//		S
		2,		//		R
		1,-4),	gate,doneAction:2);

//	-	-	-	-	-	-	-	-	-	FILTER ENVELOPE
	filtEnv = EnvGen.kr(Env.adsr(
		0.03,	//		A
		3.6,	//		D
		0.05,	//		S
		1,		//		R
		1,-4),	gate);

//	-	-	-	-	-	-	-	-	-	FILTER STAGE
	sound = RLPF.ar(sound,
		freq:			filter*filtEnv,
		rq:				resonance	) ! 2;

//	-	-	-	-	-	-	-	-	-	CHORUS EFFECT
	chorus = (DelayL.ar(sound,
		maxdelaytime:	0.08,
		delaytime:		SinOsc.kr([0.2,0.4], 0, 0.005, [0.02,0.04]),
		mul: 			0.5));

//	-	-	-	-	-	-	-	-	-	DELAY EFFECT
	delay = CombC.ar(sound,
		maxdelaytime:	0.4,
		delaytime:		[0.2,0.4],
		decaytime:		2,
		mul:			0.2);

//	-	-	-	-	-	-	-	-	-	OUTPUT MODULE
	Out.ar(0,
		(	sound + chorus + delay	) * syntEnv);

}).add;

// ***************************************************************************** //
)



MIDIIn.connectAll;

(
MIDIFunc.noteOn({arg vel, note; y = Synth(\synthBygge, [\freq, note.midicps] ).postln });
MIDIFunc.noteOff({arg vel, note; y.set(\gate, 0).postln });
)















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


