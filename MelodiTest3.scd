

språng ned ej kvart - ters ok







(
var up, down,u=1,d=1;

up = {
	u = u*0.5;
	d = d*2;
	//"up".postln;
	ä = ä+1;
};

down = {
	u = u*2;
	d = d*0.5;
	"down".postln;
	ä = ä-1;
};

// 10.do{
// 	a = [up,down].wchoose([u,d].normalizeSum);
// 	a.value;
// 	//u.post;
// 	//d.postln;
// };
)

down = {
	u = u*2;
	d = d*0.5;
	"down".postln;
	j = j-1;
	upjump = false;
	upstep = false;

};





(
var up, down,u=1,d=1, j=5, upjump = false, upstep = false, downjump =false, downstep = false, c = [1,1,1,1,1,1];
~tmp = (60/60)*4;
~bar = 0;

up = {

	if (upjump, {
		//u = u*2; d = d*0.5;
		down.value;

		} , {
			if (0.33.coin, {
				j = j+2;
				upjump = true;
				//"jumpup ".post;
				},{
					j = j+1;
					//"up ".post;
			});
	});

	u = u*0.5;
	d = d*2;
	downjump = false;
	downstep = false;

};

down = {
	if (downjump, {
		j = j-1;

		} , {
			if (0.33.coin, {
				j = j-2;
				downjump = true;
				//"jump".post;
				},{
					j = j-1;
					downjump = true;
			});
	});

	//"down ".post;
	d = d*0.5;
	u = u*2;
	upjump = false;

};



p = [64, 66, 68, 70, 71, 73, 74, 76, 66+12, 68+12, 70+12, 71+12, 73+12, 74+12, 76+12]; //lydian b7 scale

// ordered sequence of durations
//q = Pseq([1, 2, 0.5], inf).asStream;

q = {
	//c.post;
	(~bar+"  				").post;

	s = switch (["whole","haalf","tripl","quart","sxtup","eight"].wchoose(c.normalizeSum).post)

	    {"whole"} { if(~bar==0, {(~tmp/1).wait; c = [1,1,1,1,1,1];}, { "X".post; s}) }

	    {"haalf"} { (~tmp/2).wait;  ~bar = (~bar+(1/2))%1;} //c[1] = c[1] + 100%200;

	    {"tripl"} { if(~bar==0, {(~tmp/3).wait; c[2] = c[2] + 100%300; }, { "X".post; s}) }

	    {"quart"} { (~tmp/4).wait; c[3] = c[3] + 100%200; ~bar = (~bar+(1/4))%1;}

	    {"sxtup"} { if(~bar%0.5==0, {(~tmp/6).wait; c[4] = c[4] + 100%300;}, { "X".post; s} )} //~bar = (~bar+(1/6))%1;}

	    {"eight"} { (~tmp/8).wait; c[5] = c[5] + 100%400; ~bar = (~bar+(1/8))%1;}

	    {0}    { 1.wait };

	" ".postln;
};






t = Task({

	loop({
		q.value;
		x.release(2);
if(		0.9.coin,{
		a = [up,down].wchoose([u,d].normalizeSum);
		a.value;
		x = Synth(\default, [freq: p[j%p.size].value.midicps]);
		//(d+" "+u).postln;
		});

	});
});
t.start;
)
t.stop; x.release(2);





//// PdegreeToKey
