(
~drumRhythms = Dictionary.new;
~drumRhythms.put(0, [1, 0, 0, 0, 1, 0, 0]);
~drumRhythms.put(1, [0, 0, 1, 0, 0, 1, 0, 0]);
~drumRhythms.put(2, [0, 1, 0, 1, 0]);
~drumRhythms.put(3, [1, 0, 0, 0, 0, 0]);
~drumRhythms.put(4, [0, 0, 0, 0, 1, 0, 0, 0, 0]);
~drumRhythms.put(5, [0, 0, 0, 1, 0, 0, 0]);

p = Ppar(~drumRhythms.values.collect { |pattern, i|
	pattern = Pseq(~drumRhythms.at(i));
	Pn(Pbind(
		\instrument, [\kick, \snare, \hat, \tom, \brus, \brus2].at(i),
		\dur, 1/4,
		\tempo, 1,
		\amp, 0.2,
		\resSend, 0.5,
		\noteOrRest, Pif(pattern > 0, 1, Rest)
	),inf);
	}
);

~resRoutine = Pbind(
	\instrument,	\reson2,
	\degree,		[0, 2, 4, 7],
	\amp, 			0.2,
	\tempo, 		1,
	\filtr,			Pwhite(200,600),
	\pany, 			4.collect(Pwhite(-pi,pi,inf)),
	\dur, 			Pseq([4],inf),
	\octave,		4,
);
)


Synth.new(\wrenchVerb);
Synth.new(\reson);
p.play;
p.stop;

Ppar([p,~resRoutine]).play



(
//			K I C K
SynthDef(\kick, {|out = 0, amp = 0, pan, resSend = 0|
	var pop, env;
	env = EnvGen.kr(Env.perc(0.01, 0.1, 1, -5), 1, doneAction:2);
	pop = Blip.ar(50+LFNoise0.kr(10,30),1,0.5).distort;
	pop = Resonz.ar(Decay.ar(pop,TRand.ar(0.01,0.01,pop)),Demand.ar(pop,0,Dseq({ 5.rand+1 })),
		mul:Demand.ar(pop,0,Dseq({ exprand(0.5,0.67) })));
	pop = LeakDC.ar(pop*50,TRand.ar(0.9,0.9995,pop),1);
	pop	= Compander.ar(pop, pop, 0.2, slopeAbove: 1/3, add: 0, clampTime: 0.002);
	pop = Limiter.ar(pop,1);

	pop = Pan2.ar(pop*env, pan, amp*2);

	Out.ar(~resonatorSend, pop * resSend);
	Out.ar(out, pop );
}).add;

//			S N A R E
SynthDef(\snare, {|out = 0, amp = 0, pan, resSend = 0|
	var env, snare;
	env = EnvGen.kr(Env.perc(0.1, 1, 1, -5), 1, doneAction:2);
	snare = { arg i; HPF.ar(LPF.ar(
		Dust2.ar(Rand(10,100)),12000.0),60.0,
		WhiteNoise.ar(1)) *2 } ! 2;
	snare = Pan2.ar(snare*env, pan, amp/3);

	Out.ar(~resonatorSend, snare * resSend);
	Out.ar(out, snare);
}).add;

//			H A T
SynthDef(\hat, {|out = 0, amp = 0, pan, resSend = 0|
	var env, sound;
	env = EnvGen.kr(Env.perc(0.001, 0.7, 1, -5), 1, doneAction:2);
	sound = { arg i; LPF.ar(Dust.ar(
		Rand(100,400),
		LFDNoise3.ar(10).exprange(1,5)),9000.0) };
	sound = Pan2.ar(sound*env, TRand.ar(-1,1,sound), amp/3);

	Out.ar(~resonatorSend, sound * resSend);
	Out.ar(out, sound);
}).add;

//			T O M
SynthDef(\tom, {|out = 0, amp = 0, pan, resSend = 0|
	var env, sound;
	env = EnvGen.kr(Env.perc(0.1, 3, 1, -5), 1, doneAction:2);
	sound = LPF.ar(GrayNoise.ar(
		LFDNoise3.ar(60))*WhiteNoise.ar(0.2),12000.0);
	sound = Pan2.ar(sound*env, TRand.ar(-1,1,sound), amp/3);

	Out.ar(~resonatorSend, sound * resSend);
	Out.ar(out, sound);
}).add;

//			B R U S
SynthDef(\brus, {|out = 0, amp = 0, pan, resSend = 0|
	var env, sound;
	env = EnvGen.kr(Env.perc(1, 7, 0.8, -5), 1, doneAction:2);
	sound = LPF.ar(BrownNoise.ar(
		PinkNoise.ar.range(0.01,0.1)),
		Rand(3000,1200));

	sound = Pan2.ar(sound*env, TRand.ar(-1,1,sound), amp/3);
	Out.ar(~resonatorSend, sound * resSend);
	Out.ar(out, sound);
}).add;

//			B R U S 2
SynthDef(\brus2, {|out = 0, amp = 0, pan, resSend = 0|
	var env, sound;
	env = EnvGen.kr(Env.perc(0.5, 10, 1, -5), 1, doneAction:2);
	sound = HPF.ar(LPF.ar(GrayNoise.ar(LFDNoise3.ar(0.1))*WhiteNoise.ar(0.1),Rand(10000.0,14000.0)), Rand(5000.0,8000.0));
	sound = Pan2.ar(sound*env, TRand.ar(-1,1,sound), amp/3);

	Out.ar(~resonatorSend, sound * resSend);
	Out.ar(out, sound);
}).add;

)

















midNoise = LPF.ar(GrayNoise.ar(LFDNoise3.ar(60))*WhiteNoise.ar(0.009),12000.0) ! numChan;

HPF.ar(LPF.ar(GrayNoise.ar(LFDNoise3.ar(0.1))*WhiteNoise.ar(0.01),14000.0),8000.0)












(
SynthDef(\kick, {|out = 0, amp = 0, pan|
	var env, bass;
	env = EnvGen.kr(Env.perc(0.001, 0.2, 1, -4), 1, doneAction:2);
	bass = SinOsc.ar(80) + Crackle.ar(1, 0.5);
	Out.ar(out, Pan2.ar(bass*env, pan, amp));
}).add;

SynthDef(\snare, {|out = 0, amp = 0, pan|
	var env, snare;
	env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -5), 1, doneAction:2);
	snare = SinOsc.ar(120) - WhiteNoise.ar(0.5, 0.5);
	Out.ar(out, Pan2.ar(snare*env, pan, amp));
}).add;

SynthDef(\hat, {|out = 0, amp = 0, pan|
	var env, hat;
	env = EnvGen.kr(Env.perc(0.002, 0.3, 1, -2), 1, doneAction:2);
	hat = Klank.ar(`[ [ 6563, 9875 ],
		[ 0.6, 0.5 ],
		[ 0.002, 0.003] ], PinkNoise.ar(1));
	Out.ar(out, Pan2.ar(hat*env, pan, amp));
}).add;

SynthDef(\tom, {|out = 0, amp = 0, pan|
	var env, tom;
	env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -5), 1, doneAction:2);
	tom = SinOsc.ar(440);
	Out.ar(out, Pan2.ar(tom*env, pan, amp));
}).add;
)





(
fork{
	loop{ | i |
		var time, trigtime;
		time = [1/4,1].wchoose([2,10].normalizeSum);
		trigtime = [1,2,4,8,16].choose;
		play{
			var sound, freq, ampenv, filterenv, mod, snare, snaretrig, kick, kickenv, lin;

			//mod = LFNoise2.kr({0.01.rand}.dup(2), [0.01.rand,0.001.rand,0.5.rand].choose, 1.0);
			//
			// freq = [
			// 	Scale.minorPentatonic.degrees,
			// 	Scale.minorPentatonic.degrees.choose
			// ].choose + (12 * (2..6).choose);
			// freq = freq.midicps;
			//
			// filterenv = EnvGen.kr(Env.linen(time/3.0.rand.max(0.01),
			// 	time/3.0.rand.max(0.01),
			// 	time/3.0.rand.max(0.01)).range(freq*1.5,freq*10.0.rand.max(1.5))
			// );

			//ampenv = EnvGen.kr(Env.perc(0.01,time/2.0.rand.max(1/8),1.0.rand),doneAction:2);
			//
			// sound = Select.ar(5.rand, [
			// 	Pulse.ar(freq*mod,0.5).tanh,
			// 	LFTri.ar(freq*mod,0).tanh,
			// 	Pulse.ar(freq*mod,0.5).tanh,
			// 	LFSaw.ar(freq*mod,0.5).tanh,
			// 	SinOscFB.ar(freq*mod,100.0.rand).tanh
			// ]);
			//
			// sound = RLPF.ar(sound, filterenv, LFNoise2.kr(0.01.rand, 0.3, 0.5) );
			// sound = sound * ampenv;
			//
			// sound = sound + (DelayC.ar(sound, 1/4, {[1/4,1/8].choose}.dup(2)) * [1.0.rand,0]);
			//
			// 5.do{sound = (sound.clip + sound)*0.75};
			//
			//sound = LPF.ar(sound, LFNoise2.kr(trigtime, 250, 500) );

			snaretrig = Impulse.kr(trigtime);
			snare = 3*PinkNoise.ar(1!2) *
			EnvGen.kr(Env.perc(0.01,0.01,[0,0.3.rand].choose),snaretrig);
			5.do{snare = AllpassC.ar(snare, 0.5, {0.05.rand}.dup(2), 1.0.rand)+snare};
			5.do{snare = (snare.distort + snare)*0.85};

			kickenv = EnvGen.kr(Env.perc(0.01,time,[0.1,0.2.rand].choose));
			kick = SinOsc.ar(50!2+(kickenv**10*200),0,5*kickenv) * kickenv;
			5.do{kick = (kick.distort + kick)*1};

			sound = Limiter.ar(kick + snare, 0.9, 0.00001);

			Out.ar(0,sound.tanh);
		};

		time.wait;
	};
}
)


