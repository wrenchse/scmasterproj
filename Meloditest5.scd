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
	\scale, 		~scaleBuilder.value,//[0, 2, 3, 5, 7, 9, 10],
	\stepsPerOctave,12,
	\root,          ~root.value,
);

~spelaspela = Pchain(~meta1,	Ptpar([16, ~bas, 0, ~arp, 8, ~arp2, 16, ~chords, 0, ~melodi, 0, p, 0, ~resRoutine ])	)
)

~data = 7.collect( { 1-0.1.rand } );
Synth.new(\wrenchVerb, [\vol, 1]);

~spelaspela.play;


~spelaspela.stop;



// ***************************************************************************** //




MIDIIn.connectAll;


(
~synths = ();
MIDIdef.noteOn(\noteOnAction, {|vel, num|
~synths[num] = Synth(\pinguPingu, [
\freq, num.midicps,
\mod, 1,
] 	++ ~pinguPresets.at(6)
	);
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
~synths[num].set(\gate, 0);
});
)








// (
// MIDIFunc.noteOn({arg vel, note; y = Synth(\pinguPingu, [
// 	\freq, note.midicps,\lfo1s,1	]
// 	++ ~pinguPresets.at(1)
// ).postln });
//
// MIDIFunc.noteOff({arg vel, note; y.set(\gate, 0).postln });
// )
//
//
//
//
// w = Synth.new(\wowEffect);
// w.free;
//
//
//
//
//
//




































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
