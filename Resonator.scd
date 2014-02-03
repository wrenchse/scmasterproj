






(
SynthDef(\reson, { | freqs =#[50,54,57,59,62] , pitches = 0, out = 0 |
	var in, delay, dTime, pit;

	dTime = (48000/(freqs+pitches).pyramid.midicps);

	in = In.ar(out, 2);

	delay = SplayAz.ar(2,TwoTube.ar(in, LinRand(1,-1),0.995 ,dTime/4, dTime/4),1);

    //delay = CombC.ar(delay, 0.2, dTime, fb, 10)*vol;

	//LocalOut.ar(LeakDC.ar(delay*0.8));
	Out.ar(~ambiBus,delay*0.2);

},[0.5,2]).add;
)

)










(
~decoder = FoaDecoderKernel.newSpherical;
)
(

r = {
	var in, out = 0, delay, dTime, pit, freqs =#[50,54,57,59,62] , pitches = 0, fb = 1, vol = 0.5;

	pit = (freqs+pitches);
	dTime = (48000/(pit).midicps);

	in = Dust.ar(2);

//	delay = SplayAz.ar(8,TwoTube.ar(in, LinRand(1,-1),0.998 ,dTime/4, dTime/4),1);

	delay = TwoTube.ar(in, LinRand(1,-1),0.998 ,dTime/4, dTime/4);

	delay = FoaEncode.ar([delay], FoaEncoderMatrix.newOmni);

	delay = FoaTransform.ar(delay,'push',Saw.kr(1,pi));


	//delay = CombC.ar(in, 0.2, dTime, fb, 10)*vol;

	//LocalOut.ar(LeakDC.ar(delay*0.8));
	Out.ar(delay,FoaDecode.ar(delay, ~decoder));
}.play;

)



(
~decoder = FoaDecoderKernel.newSpherical;
)

~decoder = FoaDecoderKernel.newUHJ;

(

r = {
	var in, out = 0, dTime, pit, freqs =#[50,54,57,59,62] , pitches = 0, spela;

	pit = (freqs+pitches);
	dTime = (48000/(pit).midicps);

//	in = Dust.ar(2);

	spela = dTime.collect { | item, i, sound|
		sound = TwoTube.ar(Dust.ar(1), LinRand(1,-1),0.999 ,item/4, item/4);
		FoaPanB.ar(sound,Saw.kr(0.1*(i+1), mul: pi), Saw.kr(0.1*(i+1), mul: pi))}.sum;

	spela = FoaDecode.ar(spela, ~decoder);

	Out.ar(out, spela*0.5);
}.play;

)





