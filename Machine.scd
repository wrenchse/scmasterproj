Pfsm







(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05;
        var env;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction:2);
        Out.ar(out, SinOsc.ar(freq, 0, env))
    }).add;
)


(
a = Pfsm([
        #[0,1],
        67, #[0, 0, 3],
        72, #[2],
        73, #[0, 2],
        Pseq([74, 75, 76, 77]), #[2, 3, 3],
        nil, nil
    ], inf).asStream;
Routine({
    loop({
        Synth(\help_sinegrain, [\freq, a.next.midicps]);
        0.1.wait;
    })
}).play;
)
Pdsfm - för polymetriska grejer. fas tjohej, olika fraser.






(
~data = 7.collect( { 1-0.2.rand } );
//Pchain(	~pFM.(data: ~data, ieamm: 20, fdeg: 0), ~arpFM.(~data) ).play;
Pchain(	~pDrone2cm.(data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 3), ~arpu.() ).play
)

s.plotTree


~chords.play




(
~pChords = Pbind(
	\degree,		#[0, 2, 4, 7],
	\legato, 		3/4,
	\amp, 			0.2,
	\dur, 			Pseq([4],inf),
	\mtranspose, 	Pseq([0,2,5,1,7,9],inf),
	\octave, 3
);



Pchain(	~pFM.(data: ~data, ieamm: 2, fdeg: 0), ~pChords ).play;
)

~chords.play


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
	\mtranspose, 	Pseq([0,2,5,1,7,9]),
	*~pinguPresets.at(1),

);




(
// this kick drum doesn't sound so good on cheap speakers
// but if your monitors have decent bass, it's electro-licious
SynthDef(\kik, { |basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1,
	decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
	var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
	sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
	Out.ar(out, sig ! 2)
}).add;

SynthDef(\kraftySnr, { |amp = 1, freq = 2000, rq = 3, decay = 0.3, pan, out|
	var    sig = PinkNoise.ar(amp),
	env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
	sig = BPF.ar(sig, freq, rq, env);
	Out.ar(out, Pan2.ar(sig, pan))
}).add;

~commonFuncs = (
	// save starting time, to recognize the last bar of a 4-bar cycle
	init: {
		if(~startTime.isNil) { ~startTime = thisThread.clock.beats };
	},
	// convert the rhythm arrays into patterns
	pbindPairs: { |keys|
		var    pairs = Array(keys.size * 2);
		keys.do({ |key|
			if(key.envirGet.notNil) { pairs.add(key).add(Pseq(key.envirGet, 1)) };
		});
		pairs
	},
	// identify rests in the rhythm array
	// (to know where to stick notes in)
	getRestIndices: { |array|
		var    result = Array(array.size);
		array.do({ |item, i|
			if(item == 0) { result.add(i) }
		});
		result
	}
);
)

(
TempoClock.default.tempo = 104 / 60;

~kikEnvir = (
	parent: ~commonFuncs,
	// rhythm pattern that is constant in each bar
	baseAmp:	#[1, 0, 0, 0,  0, 0, 0.7, 0,  1, 0, 0, 0,  0, 0, 0, 0] * 0.5,
	baseDecay: #[0.15, 0, 0, 0,  0, 0, 0.15, 0,  0, 0.15, 0, 0,  0, 0, 0, 0],
	addNotes: {
		var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = ~getRestIndices.(~baseAmp);
		~amp = ~baseAmp.copy;
		~decay2 = ~baseDecay.copy;
		// if last bar of 4beat cycle, do busier fills
		if(beat16pos.inclusivelyBetween(12, 16)) {
			available.scramble[..rrand(5, 10)].do({ |index|
				// crescendo
				~amp[index] = index.linexp(0, 15, 0.2, 0.5);
				~decay2[index] = 0.15;
			});
		} {
			available.scramble[..rrand(0, 2)].do({ |index|
				~amp[index] = rrand(0.15, 0.3);
				~decay2[index] = rrand(0.05, 0.1);
			});
		}
	}
);

~snrEnvir = (
	parent: ~commonFuncs,
	baseAmp: #[0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0] * 1.5,
	baseDecay: #[0, 0, 0, 0,  0.7, 0, 0, 0,  0, 0, 0, 0,  0.4, 0, 0, 0],
	addNotes: {
		var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = ~getRestIndices.(~baseAmp),
		choice;
		~amp = ~baseAmp.copy;
		~decay = ~baseDecay.copy;
		if(beat16pos.inclusivelyBetween(12, 16)) {
			available.scramble[..rrand(5, 9)].do({ |index|
				~amp[index] = index.linexp(0, 15, 0.5, 1.8);
				~decay[index] = rrand(0.2, 0.4);
			});
		} {
			available.scramble[..rrand(1, 3)].do({ |index|
				~amp[index] = rrand(0.15, 0.3);
				~decay[index] = rrand(0.2, 0.4);
			});
		}
	}
);

~hhEnvir = (
	parent: ~commonFuncs,
	baseAmp: 15 ! 16,
	baseDelta: 0.25 ! 16,
	addNotes: {
		var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = (0..15),
		toAdd;
		// if last bar of 4beat cycle, do busier fills
		~amp = ~baseAmp.copy;
		~dur = ~baseDelta.copy;
		if(beat16pos.inclusivelyBetween(12, 16)) {
			toAdd = available.scramble[..rrand(2, 5)]
		} {
			toAdd = available.scramble[..rrand(0, 1)]
		};
		toAdd.do({ |index|
			~amp[index] = ~doubleTimeAmps;
			~dur[index] = ~doubleTimeDurs;
		});
	},
	doubleTimeAmps: Pseq(#[15, 10], 1),
	doubleTimeDurs: Pn(0.125, 2)
);


~kik = Penvir(~kikEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kik,
			\preamp, 0.4,
			\dur, 0.25,
			*(~pbindPairs.value(#[amp, decay2]))
		),
		// default Event checks \freq --
		// if a symbol like \rest or even just \,
		// the event is a rest and no synth will be played
		\freq, Pif(Pkey(\amp) > 0, 1, \rest)
	)
}), inf)).play(quant: 4);

~snr = Penvir(~snrEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kraftySnr,
			\dur, 0.25,
			*(~pbindPairs.value(#[amp, decay]))
		),
		\freq, Pif(Pkey(\amp) > 0, 5000, \rest)
	)
}), inf)).play(quant: 4);

~hh = Penvir(~hhEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kraftySnr,
			\rq, 0.06,
			\amp, 15,
			\decay, 0.04,
			*(~pbindPairs.value(#[amp, dur]))
		),
		\freq, Pif(Pkey(\amp) > 0, 12000, \rest)
	)
}), inf)).play(quant: 4);
)

// stop just before barline
t = TempoClock.default;
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
	[~kik, ~snr, ~hh].do(_.stop);
});








