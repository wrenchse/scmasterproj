




(
{

d = {
	var out, freq = 50, mod = 1;

	out = 4.collect({
		arg i;
		freq = freq * 2;
		[SinOscFB.ar(freq/1.5, SinOsc.kr(0.04*(i+1)/5,-1,mod,1),0.3/(i+1)/3),
		SinOscFB.ar(freq, SinOsc.kr(0.02*(i+1/5),-1,mod,1),0.3/(i+1)/5)]
	});

	//Out.ar([0,1], [out]);
};


p = {
	var out, out2, freq = 50, mod = 1;

	out = 4.collect({
		arg i;
		freq = freq * 2;
		[PMOsc.ar(freq/2, freq/2*SinOsc.kr(0.01,0,0.01,1),1)*0.1/(i+1),
			PMOsc.ar(freq/2, freq*1.5*SinOsc.kr(0.01,0,0.01,1),1)*0.05/(i+1)]
	});

	out2 = Resonz.ar(out, [(1..4)*freq], 0.4,5);

	//out = PMOsc.ar(freq, freq*SinOsc.kr(0.01,0,1,1),1)*0.1;

	//Out.ar([0,1], [out]+[out2]);
};

	o = Mix.new(d+p)*0.6;
	//o = BLowPass4.ar(o, MouseX.kr(20,20000,\exponential), 2);
	//o = CombN.ar(o, 0.2, 0.2, 3);

Out.ar([0,1],o);


}.play

)