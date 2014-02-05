


(

SynthDef(\reson, { | freqs = #[1] , pitches = 0, out = 0 |
	var in, delay, dTime, pit, spela, ut;

	pit = (freqs+pitches);
	dTime = (48000/(pit).midicps);

	in = Mix.ar(In.ar(20,4))*0.5;

//	In.ar(20+(i%3),1) Kan bytas ut mot in i TwoTuben.

	spela = dTime.collect { | item, i, sound|
		sound = TwoTube.ar(Dust(10), LinRand(1,-1),0.9 ,item/4, item/4);
		FoaPanB.ar(sound,LFSaw.ar(0.05*(i/5+0.1), mul: pi), LFSaw.ar(0.05*(i/5+0.1), mul: pi))}.sum;

	Out.ar(~reverbSend, spela*0.2);

	ut = FoaDecode.ar(spela, ~decoder);

	Out.ar(out, ut);
}).add;
)



Synth.new(\reson);








(
SynthDef(\reson, { | freqs =#[50,54,57,59,62] , pitches = 0, out = 0 |
	var in, delay, dTime, pit;

	dTime = (48000/(freqs+pitches).pyramid.midicps);

	in = In.ar(out, 2);

	delay = SplayAz.ar(2,TwoTube.ar(in, LinRand(1,-1),0.995 ,dTime/4, dTime/4),1);

    //delay = CombC.ar(delay, 0.2, dTime, fb, 10)*vol;

	//LocalOut.ar(LeakDC.ar(delay*0.8));
	Out.ar(0,delay*0.2);

},[0.5,2]).add;
)

)





(
~decoder = FoaDecoderKernel.newSpherical;
)

~decoder = FoaDecoderKernel.newUHJ;

(


r = {
	var in, out = 0, dTime, pit, freqs =#[50,54,57,59,62] , pitches = 0, spela, ut;

	pit = (freqs+pitches);
	dTime = (48000/(pit).midicps);

	//in = Dust.ar(2);

	spela = dTime.collect { | item, i, sound|
		sound = TwoTube.ar(Dust.ar(0.2), LinRand(1,-1),0.999 ,item/4, item/4);
		FoaPanB.ar(sound,LFSaw.ar(0.05*(i/2+0.1), mul: pi), LFSaw.ar(0.5*(i/2+0.1), mul: pi))}.sum;

	Out.ar(~reverbSend, spela);

	ut = FoaDecode.ar(spela, ~decoder);

	Out.ar(out, ut);
//	Out.ar(out, spela);
}.play;

)





