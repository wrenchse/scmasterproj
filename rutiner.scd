
//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//

//				//	-	-	-	-	-	-	-	-	-	-	//
//				//			 MELODY GENERATOR 9001			//
//				//			  A.K.A THE BACHINATOR			//
//				//			(c)JONTE KJELLBERGSSON			//
//				//	-	-	-	-	-	-	-	-	-	-	//
~melodyNotes2 = { | seed = 100 |
	var newNote, 	noteOut = 0, 	forceDown = 0, 	noDownJump = 0, 	up, 	down;

//	-	-	-	-	-	-	UP
	thisThread.randSeed = seed;

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
	newNote = 100.collect{ |i|
		if (LinLin.kr(forceDown + noteOut,-14, 14,1,0).coin,
			{
				up.value
			},{
				down.value
			}
	);
		noteOut;
	};

};


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

//	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	//


thisThread.randSeed = ~seed;

~melodi = 	Pbind(
	\instrument, 	\pinguPingu, 			//Pstutter(5,Pseq(.[\restrument,\default],inf)),
	\dur, 			Pseq(~melodyDur.value.flat),
	\degree, 		Pseed(~seed,~melodyNotes),
	\scale,         ~scaleBuilder.value,
	\octave,		6,
	\amp,			0.2,
	\gate, 			1,
//	\detune, [1,7,-5,-2,-4],
	\filtr,			Pwhite(1000,3000),
		\pan, 			Pwhite(-0.1,0.1,inf),
	*~pinguPresets.at(3),
);

~arp = 		Pbind(
	\degree,		Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
	\legato, 		1/4,
	\amp, 			0.4,
	\filtr,			Pwhite(300,1200),
	\dur, 			Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
	\octave,		4,
	\pan, 			Pwhite(-0.2,0.2,inf),
	\scale, 		~scaleBuilder.(~data),//[0, 2, 3, 5, 7, 9, 10],
	\root,          ~root.(~data),
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


~metaNotes = { | data  |
	6.collect {|i|
		LinLin.kr(data[i],data.sum/7,1.0,0,24).round
	};
};














































/*
(
var toner, length;
thisThread.randSeed = 10;

toner = 10.collect{ |i| ~melodyNotes2.().[i] };
length= 10.collect{ |i| ~melodyDur.().flatten[i] };

Ppar( 4.collect{
	arg i;
Pbind(*[
	instrument: \default, //\droneWrench,
		dur: 			Pseq(length,inf),
//		dur: 10-i,
		stretch: 2/(i+1.2),
		degree: Pseq(toner,inf),
		octave: 4,
		scale: ~scaleBuilder.value,
])
}).play
)*/

/*
(
~melodi2 = {	arg number = 1, dur = 0.2;
Pbind(
	\dur, 			dur,
	\scale, 		~scaleBuilder.(~data),
	\degree,        Pseq((0..7),1),
	\octave,		number,
	\amp,			0.2,
	\root,          ~root.value,
	\gate, 			1,
	\filtr,			Pwhite(1000,3000),
	\pan, 			Pwhite(-0.1,0.1,inf),
)};
)*/