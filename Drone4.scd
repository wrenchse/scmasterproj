




(
Synth.new(\wrenchVerb, [\vol, 1]);
//Synth.new(\reson, [\pitches, 0]);
)


(
SynthDef(\droneWrench, { |
	out		=	0, 		freq 	=	60,		mod	=	0.2,
	revLev 	=	0.5,	resLev 	=	0,		amp	=	1,
	gate 	= 	1,		deviat	=	1.0, 	data = #[1,1,1,1,1,1,1],
	env 	= #[10,	0.1,	1,		10]		|

	var drone1, drone2, freq1 = freq, sound, envelope, phase, summa;

	phase = LinLin.kr(data.sum/7,0.8,1.0,pi/2,-pi/2);
	summa = abs(LinLin.kr(data.sum/7, 0.9, 1.0,0,10));
	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: 2);

	drone1 = 4.collect{
		arg i;
		var a;
		a =[
			SinOscFB.ar(
				freq1*(1-(data[i]/20)),
				SinOsc.ar(0.001*data[i],	phase,mod/(1*data[i]),0+(i%3*0.5)),
				0.6/(i+(1*data[i]))),
			SinOsc.ar(
				freq1*2,
				SinOsc.ar(0.02*(i+1/data.sum)*(deviat*10), phase*data[i]*2,mod/4*deviat,1),
				0.3/(i+1))/3];

		freq1 = freq1 * 2;
		a;
	};

	freq1 = freq;

	drone2 = 4.collect {
		arg i;
		freq1 = freq1 * 2;
		Resonz.ar(
			[
				PMOsc.ar(freq1*(1-(data[i]/3)), freq1/2*SinOsc.kr(0.01,0,0.01,1),summa,summa%pi)*0.2/(i+1),
					PMOsc.ar(freq1*(1-(data[i]/3)), freq1*1.5*SinOsc.kr(0.1,0,0.1,1), summa*data[i])*0.2/(i+1)],
			[(1..3)*(freq*summa)],
			1,summa*data[i]+0.5)
	};

	drone1 = FoaEncode.ar(drone1, FoaEncoderMatrix.newPanto);
	drone1 = FoaTransform.ar(drone1,
		'rotate',LFSaw.ar(0.1,mul: pi, iphase: summa/5));

	drone2 = FoaEncode.ar(drone2, FoaEncoderMatrix.newPanto);
	drone2 = FoaTransform.ar(drone2,
		'rotate',LFSaw.ar(0.1,mul: -pi, iphase: summa/5));

	sound = (drone1+drone2)*envelope;
	sound = FoaDecode.ar(sound, ~decoder);

	Out.ar(out, sound*amp);

	//Out.ar(20, d*0);

	Out.ar(~reverbSend, (sound*1)*revLev);

}).add;
)


MIDIIn.connectAll;


(
~synths = ();

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth(\droneWrench, [
		\freq, num.midicps,
		\mod, 0.2,
		\deviat, ~dev,
		\data, [~data],
		\env, [20,0,1,2]
	]);
	~data = 7.collect( { 1-0.1.rand } );
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].set(\gate, 0);
});
)


(

~dev = ~data.sum/7;
)

[0,4,9,1].sort

-pi/2.sin




(
~data = 7.collect( { 1-0.1.rand } );

~pDrone = { arg dur = 60, data, octave;
	Pbind(*[
		instrument: \droneWrench,
		dur: dur,
		amp: 0.5,
		octave: octave,
		data: [data],
		root: ~root.(data),
		mod: 0.2,
/*		group: ~sG*/
	])
};
~pDrone.(dur: 60, data: ~data, octave: 1).play;
)


(
p = Pspawn(Pbind(
	// Pbind returned by Pfunc is not embedded, just placed in the event
	// So, it can be spawned
	\pattern, ~pDrone.(dur: 10, data: ~data, octave: Pseq([1,2]));,
	\dur, 5,
	\method, \par,
/*	\target, ~sG*/
)).play;
)

p.stop




s.plotTree

~data = 7.collect( { 1-0.2.rand } );
~pDrone2cm.(dur: Pseq([10],2), data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 1).play

p.next
p.play
p.stop
~pDrone2cm.().stop

(
~data = 7.collect( { 1-0.2.rand } );
p = Pspawn(Pbind(
	// Pbind returned by Pfunc is not embedded, just placed in the event
	// So, it can be spawned
	\pattern, Pfunc(Pseq([~pDrone2cm.(dur: 4, data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 3), Pchain(	~pFM.(data: ~data, ieamm: 20, fdeg: 0), ~arpP.(~data,4) )])),
	\dur, 10,
	\method, \seq,

)).play;
)



(
~pFM = { arg dur = 60, data, octave=4, bus = 62, mod = 1, amm = 1, index= 0, mp =1, cp=1, st =1, deg = 0, fdeg=12, iespeed=0, ieamm = 10, env = #[0,1,0.8,1];
	Pgroup(
	Ppar([
		Pbind(*[
			instrument: \wModulator,
			root: ~root.(data),
			addAction: 0,
			modPartial: mp,
			index: index,
			ctranspose: fdeg,
			mul: 1 - (0.2),
			data: [data],
			iespeed: dur+env[3],
			ieamm: ieamm,
			outbus: bus,
		])]
		++	[
			Pbind(*[
				instrument: \wCarrier,
				root: ~root.(data),
				addAction: 1,
				carPartial: cp,
				index: index/2,
				speed: 1,
				inbus: bus,
				da: 2,
	])],1)
	)
};
)
(
~data = 7.collect( { 1-0.2.rand } );
~pFM.(data: ~data, octave: 4, index: 10).play;
)
Env.circle(LinLin.kr(~data,0.8,1.0,0,1),~data,[-5, 0, -5]).plot;



~data = 7.collect( { 1-0.2.rand } );


Pchain(	~pFM.(data: ~data, ieamm: 20, fdeg: 0), ~arpP.(~data,4) ).play




(
~arpP = { | data, oct = 2 |

	Pbind(
		\degree,		Pseq(4.collect{[0, 2, 4, 7].scramble}.flat,inf),
		\legato, 		Pn(Prand([1/2,1/4,1/8],1),inf),
		\tempo,         100/120,
		\amp, 			0.4,
		\dur, 			Pn(Pseq((8.collect{1/4} ++ 16.collect{1/8}).scramble),inf,\step),
		\octave,		oct,
		\pan, 			Pwhite(-0.2,0.2,inf),
		\scale, 		~scaleBuilder.(data),//[0, 2, 3, 5, 7, 9, 10],
		\root,          ~root.(data),
		\env,           [[0.01,0.1,0.2,0.5]],
	);
}
)


~chordsP = { | data, oct = 3 |

	Pbind(
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

	);
}










~data = 7.collect( { 1-0.02.rand } );
LinLin.kr(~data,~data.minItem,~data.maxItem,0,4).round







(
e = (
    a: ~pFM.(dur: 1, data: ~data, octave: 4, index: 10, amm: ~data, deg: 0, fdeg: 0, ieamm: 2, env: [0.01,1,0.2,0.1] ),
    b: ~pFM.(dur: 0.4, data: ~data, octave: 2, index: 10, amm: ~data, deg: 0, fdeg: 0, ieamm: 2, env: [0.01,1,0.2,0.1] ),
    c: Pbind(\dur, 0.3, \degree, Pseq([0, 1, 2], 2))
);

)



(
e = [Pchain(	~pFM.(data: ~data, ieamm: 20, fdeg: 0), ~arpP.(~data,4) )];
x = Pseq([e[0]]);
x.play;
)

Pnsym









