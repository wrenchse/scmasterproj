(
SynthDef(\help_Env_newClear, { |out = 0, length = 10 |
	    var env, envctl, trigger = Trig.kr(Impulse.kr(10/length),length);
    // make an empty 4 segment envelope
    env = Env.newClear(16);
    // create a control argument array
    envctl = \env.kr(env.asArray);
    Out.ar(out,
        SinOsc.ar(EnvGen.kr(envctl, trigger), 0, 0.3) // the gate control is a trigger
    );
}).add;
)







~data = 7.collect( { 1-0.1.rand } );

(
var i = 6, l = 1;
	~env = 7.collect { |i| 	Env(LinLin.kr(~data.rotate(i).slide(i+1,1),0.8,1.0,100,1000),1*l)
	};

)
~env[0].
~long = ~env[i].collect { 1 }.sum;

Synth(\help_Env_newClear, [
	\gate, 1,
	\env, Env(LinLin.kr(~env[i],0.8,1.0,100,1000),1*l),
	\length, (~long-1)*l ]); // 3 segments
~env[i].plot
)



// reset then play again:
Synth(\help_Env_newClear, [\gate, 1, \env, Env({ rrand(60, 70).midicps } ! 4, [1,1,1], \exp)]);

// the same written as an event:
(instrument: \help_Env_newClear, gate: 1, env: Env({ rrand(60, 70).midicps } ! 4, [1,1,1], \exp)).play;


Trig.kr

