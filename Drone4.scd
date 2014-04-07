SynthDef(\droneWrench, { |
	out		=	0, 		freq 	=	60,		mod	=	0.2,
	revLev 	=	0.5,	resLev 	=	0,		amp	=	1,
	gate 	= 	1,		deviat	=	1.0, 	data = #[1,1,1,1,1,1,1],
	env 	= #[10,	0.1,	1,		10]		summa = 1, phase = 0 |

	var drone1, drone2, freq1 = freq, sound, envelope;

	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: 2);

	drone1 = 4.collect{
		arg i;
		var a;
		a =[
			SinOscFB.ar(
				freq1*(1-(data[i]/20)),
				SinOsc.ar(0.001*data[i]*i,	phase*data[i]*i,mod/(1*data[i]),0),
				0.8/(i+(5*data[i]))),
			SinOsc.ar(
				freq1*2,
				SinOsc.ar(0.02*(i+1/data.sum)*(deviat*10), phase*data[i]*2,mod/4*deviat,1),
				0.1/(i+1))/3
		];

		freq1 = freq1 * 2;
		a;
	};

	freq1 = freq;

	drone2 = 4.collect {
		arg i;
		freq1 = freq1 * 2;
		Resonz.ar(
			[
				PMOsc.ar(freq1*(1-(data[i]/3)), freq1/2*SinOsc.kr(0.01,0,0.01,1),summa,summa%pi)*0.5/(i+1),
				PMOsc.ar(freq1*(1-(data[i]/3)), freq1*1.5*SinOsc.kr(0.1,0,0.1,1), summa*data[i])*0.5/(i+1)],
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


	Out.ar(~reverbSend, (sound*1)*revLev);
	Out.ar(out, sound*amp);

	//Out.ar(20, d*0);
}).add;






~playDRONE2 = {|out=0,le=16,dec=4|
	var d, play;
	~pDrone = { | data, octave, dev = 2,amp=0.5 |
		Pmono(*[
			\droneWrench,
			amp: amp,
			octave: octave,
			data: [data],
			mod: 2,
			env: [[30,0,1,20]],
			summa: abs(LinLin.kr(data.sum/7, 0.7, 1.0, dev, 0)),
			phase: LinLin.kr(data.sum/7,data.minItem, data.maxItem,pi/2,-pi/2),
			out: out,
			group: ~groups[3]
		])
	};

	d = Array.fill(9);
	d[0] = { ~pDrone.(~data, 1,5,amp:1	)<>(degree: 0) };
	d[1] = { ~pDrone.(~data, 2			)<>(degree: 2) };
	d[2] = { ~pDrone.(~data, 3			)<>(degree: 4) };
	d[3] = { ~pDrone.(~data, 3			)<>(degree: 0) };
	d[4] = { ~pDrone.(~data, 3			)<>(degree: 2) };
	d[5] = { ~pDrone.(~data, 2			)<>(degree: 7) };
	d[6] = { ~pDrone.(~data, 1			)<>(degree: 6) };
	d[7] = { ~pDrone.(~data, 4			)<>(degree: 3) };
	d[8] = { ~pDrone.(~data, 5,amp:0.2	)<>(degree: 3) };


	play = Pspawn(
		Pbind(
			\pattern, {Pxrand(d.collect{|i,n| Psync(d[n].(),4,le*dec)})},
			\delta, le,
			\method, Pseq([\par,Prand([\par,\wait],inf)]),
		)
	);
};













// MIDIIn.connectAll;
// (
// ~synths = ();
//
// MIDIdef.noteOn(\noteOnAction, {|vel, num|
// 	~synths[num] = Synth(\droneWrench, [
// 		\freq, num.midicps,
// 		\mod, 0.2,
// 		\deviat, ~dev,
// 		\data, [~data],
// 		\env, [20,0,1,2]
// 	]);
// 	~data = 7.collect( { 1-0.1.rand } );
// });
// MIDIdef.noteOff(\noteOffAction, {|vel, num|
// 	~synths[num].set(\gate, 0);
// });
// )