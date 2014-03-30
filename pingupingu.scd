
// ***************************************************************************** //
(

~pinguPresets = Dictionary.new;
~pinguPresets.put(1, [	\envSynth,	[[2,0.1,0.9,5]],	\envFilter,	[[0.01,5,1,10]], \res,  1, \filtr, 1000, \revAmm, 0.5	 ]  ); // "1".asSymbol
~pinguPresets.put(2, [	\envSynth,	[[0.01,0.5,0.02,1]],	\envFilter,	[[0.01,0.1,0.4,1]], \res,  0.5, \saw0Pulse1, 0, \pulseWidth, 0.5	 ]  );
~pinguPresets.put(3, [	\envSynth,	[[0.01,2,0.2,1.1]],	\envFilter,	[[0.01,0.3,0.3,0.1]], \res,  1, \saw0Pulse1, 1, \pulseWidth, 0.05, \delDecay, 5, \revAmm, 0.5	 ]  );
~pinguPresets.put(4, [	\envSynth,	[[0.1,1.4,0.4,1.5]],	\envFilter,	[[0.1,2,0.2,1.5]], \res,  1]  );

~pinguPresets.put(5, [	\envSynth,	[[0.01,0.01,1.5,0.01]],	\envFilter,	[[0,0.0,0.7,0]], \res,  0.3, \filtr, 100, \revAmm, 0.5, \saw0Pulse1, 1	 ]  ); // "1".asSymbol
~pinguPresets.put(6, [	\envSynth,	[[0.01,1,0.01,0.1]],	\envFilter,	[[0.005,0.01,0.1,1]], \res,  0.08, \filtr,1000, \saw0Pulse1, 0, \delAmm, 0	 ]  );



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
	revAmm		= 0.1,	delAmm		= 0.2,

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
		mul:			delAmm);

	sound = sound + chorus + delay;

DetectSilence.ar(sound, doneAction:2);
//	-	-	-	-	-	-	-	-	-	OUTPUT MODULE
	Out.ar(~reverbSend,sound * revAmm/2);
	Out.ar(0,
		(	sound 	) * amp);



}).add;

// ***************************************************************************** //
)