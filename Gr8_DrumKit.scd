// *-- Drum Set --* //

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////--- SYNTH BANK ---/////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
// --- hi-hat --- //

SynthDef("hh", {
    arg noiseRel = 0.25, noiseLevel=0.2, ffreq=9853, q=0.6, amp=0.3;
    var noiseOsc = BBandPass.ar(PinkNoise.ar(), ffreq, q);
	var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel), doneAction: 2);
    var snd = noiseOsc * noiseEnv * 6*amp;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;


// --- snare drum --- //

SynthDef("sn", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;


// --- kick --- //

SynthDef("kc", {
	arg amp=0.1, pan=0, start=472;
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(start, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, pan, amp));
}).add;


// --- clap --- //

SynthDef("ce", {
    |out = 0, amp = 0.5, pan = 0, dur = 1, value = 7600|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, value);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;


// --- tom --- //

SynthDef("tom", {
    arg startPitch = 1000, endPitch=60, clickLevel=0.7, pitchRel = 0.36, noiseLevel=1, noiseRel= 0.3, amp=0.1;
    var pitchEnv = EnvGen.ar(Env.perc(0.01, pitchRel));

    var clickOsc = SinOsc.ar(pitchEnv*(startPitch-endPitch)+endPitch);
    var clickEnv = EnvGen.ar(Env.perc(0.001, pitchRel))*clickLevel;
    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel), doneAction:2)*noiseLevel;
    var snd =  noiseOsc * noiseEnv +clickOsc *clickEnv;
	snd = snd*amp;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;
)


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////// Supercollider <--> GUI ///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
var hh, sn, kc, ce, tom, knob_names, drum_kit_win;
~hh_knobs;
~sn_knobs;
~kc_knobs;
~ce_knobs;
~tom_knobs;

~kickIndex = 1;
~snareIndex = 2;
~hihatIndex = 3;
~clapIndex = 4;
~tomIndex = 5;

~ffreq_hh_temp = 9850;
~amp_hh_temp = 0.125;

~sinfreq_temp = 180;
~amp_sn_temp = 0.25;

~start_temp = 475;
~amp_kc_temp = 0.5;

~value_temp = 7600;
~amp_clap_temp = 0.125;

~startPitch_temp = 125;
~amp_tom_temp = 0.25;

~keys2synth;

knob_names = Array2D.new(5, 3);
~keys2synth = Array.newClear(5);

drum_kit_win = Window.new(name: "Drum Set", bounds: Rect(100,200,580,370)).background_(Color.grey(0.7)).front;

drum_kit_win.view.keyDownAction = {
	arg view, char, modifiers, unicode, keycode;
	var chosen_synth;

x = case

	{ keycode == ~keys2synth[0]  } { chosen_synth = Synth(\hh, [\ffreq, ~ffreq_hh_temp, \amp, ~amp_hh_temp]);}

	{ keycode == ~keys2synth[1]  } { chosen_synth = Synth(\sn, [\sinfreq, ~sinfreq_temp, \amp, ~amp_sn_temp]);}

	{ keycode == ~keys2synth[2]  } { chosen_synth = Synth(\kc, [\start, ~start_temp, \amp, ~amp_kc_temp]);}

	{ keycode == ~keys2synth[3]  } { chosen_synth = Synth(\ce, [\value, ~value_temp, \amp, ~amp_clap_temp]);}

	{ keycode == ~keys2synth[4] } { chosen_synth = Synth(\tom, [\startPitch, ~startPitch_temp, \amp, ~amp_tom_temp]); };

	postln(x);
};

///////////////////////////////////// hi-hat /////////////////////////////////////

hh = Button.new(drum_kit_win,Rect(30,10,80,80)).states_([["Hi-Hat", Color.black, Color.fromHexString("A1E7F0")]]);

hh.mouseDownAction = {
	var hit_hat;
	hit_hat = Synth(\hh, [\ffreq, ~ffreq_hh_temp, \amp, ~amp_hh_temp]);
};

~hh_knobs = Array.newClear(2);

~hh_knobs[0] = Knob(drum_kit_win,Rect(30,130,80,80));
~hh_knobs[0].value = ~ffreq_hh_temp/15000;
~hh_knobs[0].action = {~ffreq_hh_temp = ~hh_knobs[0].value.linlin(0, 1, 100, 15000);
						postln(~ffreq_hh_temp);
					};
knob_names[0,0] = StaticText(drum_kit_win,Rect(35+5,200,90,30)).string_("HH_Freq");

~hh_knobs[1] = Knob(drum_kit_win,Rect(30,250,80,80));
~hh_knobs[1].value = ~amp_hh_temp/3;
~hh_knobs[1].action = {~amp_hh_temp = ~hh_knobs[1].value.linexp(0, 1, 0.01, 3);
						postln(~amp_hh_temp);
					};
knob_names[0,1] = StaticText(drum_kit_win,Rect(40+15,200+120,90,30)).string_("AMP");


///////////////////////////////////// snare /////////////////////////////////////

sn = Button.new(drum_kit_win,Rect(140,10,80,80)).states_([["Snare", Color.black, Color.fromHexString("64C5D7")]]);

sn.mouseDownAction = {
	var snare;
	snare = Synth(\sn, [\sinfreq, ~sinfreq_temp, \amp, ~amp_sn_temp]);
};

~sn_knobs = Array.newClear(2);

~sn_knobs[0] = Knob(drum_kit_win,Rect(140,130,80,80));
~sn_knobs[0].value = ~sinfreq_temp/1000;
~sn_knobs[0].action = {~sinfreq_temp = ~sn_knobs[0].value.linexp(0, 1, 80, 1000);
						postln(~sinfreq_temp);
					};
knob_names[1,0] = StaticText(drum_kit_win,Rect(25+120,200,90,30)).string_("SN_Release");

~sn_knobs[1] = Knob(drum_kit_win,Rect(140,250,80,80));
~sn_knobs[1].value = ~amp_sn_temp/2;
~sn_knobs[1].action = {~amp_sn_temp = ~sn_knobs[1].value.linexp(0, 1, 0.01, 2);
						postln(~amp_sn_temp);
					};
knob_names[1,1] = StaticText(drum_kit_win,Rect(40+125,200+120,90,30)).string_("AMP");


///////////////////////////////////// kick /////////////////////////////////////

kc = Button.new(drum_kit_win,Rect(250,10,80,80)).states_([["Kick", Color.black, Color.fromHexString("3399BD")]]);

kc.mouseDownAction = {
	var kick;
	kick = Synth(\kc, [\start, ~start_temp, \amp, ~amp_kc_temp]);
};
~kc_knobs = Array.newClear(2);

~kc_knobs[0] = Knob(drum_kit_win,Rect(250,130,80,80));
~kc_knobs[0].value = ~start_temp/2000;
~kc_knobs[0].action = {~start_temp = ~kc_knobs[0].value.linlin(0, 1, 40, 2000);
						postln(~start_temp);
					};
knob_names[2,0] = StaticText(drum_kit_win,Rect(18+245,200,90,30)).string_("Kick_Freq");

~kc_knobs[1] = Knob(drum_kit_win,Rect(250,250,80,80));
~kc_knobs[1].value = ~amp_kc_temp/2;
~kc_knobs[1].action = {~amp_kc_temp = ~kc_knobs[1].value.linexp(0, 1, 0.01, 2);
						postln(~amp_kc_temp);
					};
knob_names[2,1] = StaticText(drum_kit_win,Rect(40+235,200+120,90,30)).string_("AMP");


///////////////////////////////////// clap /////////////////////////////////////

ce = Button.new(drum_kit_win,Rect(360,10,80,80)).states_([["Clap", Color.black, Color.fromHexString("206A9D")]]);

ce.mouseDownAction = {
	var clap;
	clap = Synth(\ce, [\value, ~value_temp, \amp, ~amp_clap_temp]);
};
~ce_knobs = Array.newClear(2);

~ce_knobs[0] = Knob(drum_kit_win,Rect(360,130,80,80));
~ce_knobs[0].value = ~value_temp/9000;
~ce_knobs[0].action = {~value_temp = ~ce_knobs[0].value.linlin(0, 1, 200, 9000);
						postln(~value_temp);
					};
knob_names[3,0] = StaticText(drum_kit_win,Rect(15+350,200,90,30)).string_("Clap_Freq");

~ce_knobs[1] = Knob(drum_kit_win,Rect(360,250,80,80));
~ce_knobs[1].value = ~amp_clap_temp/3.5;
~ce_knobs[1].action = {~amp_clap_temp = ~ce_knobs[1].value.linexp(0, 1, 0.01, 3.5);
						postln(~amp_clap_temp);
					};
knob_names[3,1] = StaticText(drum_kit_win,Rect(40+345,200+120,90,30)).string_("AMP");


///////////////////////////////////// tom /////////////////////////////////////

tom = Button.new(drum_kit_win,Rect(470,10,80,80)).states_([["Tom", Color.black, Color.fromHexString("004C8D")]]);

tom.mouseDownAction = {
	var tom;
	tom = Synth(\tom, [\startPitch, ~startPitch_temp, \amp, ~amp_tom_temp]);
};

~tom_knobs = Array.newClear(2);

~tom_knobs[0] = Knob(drum_kit_win,Rect(470,130,80,80));
~tom_knobs[0].value = ~startPitch_temp/2000;
~tom_knobs[0].action = {~startPitch_temp = ~tom_knobs[0].value.linexp(0, 1, 100, 2000);
						postln(~startPitch_temp);
					};
knob_names[4,0] = StaticText(drum_kit_win,Rect(18+460,200,90,30)).string_("Tom_Start");

~tom_knobs[1] = Knob(drum_kit_win,Rect(470,250,80,80));
~tom_knobs[1].value = ~amp_tom_temp/3;
~tom_knobs[1].action = {~amp_tom_temp = ~tom_knobs[1].value.linexp(0, 1, 0.01, 3);
						postln(~amp_tom_temp);
					};
knob_names[4,1] = StaticText(drum_kit_win,Rect(40+455,200+120,90,30)).string_("AMP");

)


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////---ARDUINO CONSTANTS DEFINITIONS---///////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
~playCommand = $d;
~sonar = $s;
~fotoResistor = $f;
~potentiometer1 = $p;
~potentiometer2 = $k;
~commandTerminator = $t;
~charArray = [ ];

//Hardware range values
~fotoresistorMin = 60;
~fotoresistorMax = 680;
~potentiometerMin = 0;
~potentiometerMax = 680;
~kPotentiometerMin = 0;
~kPotentiometerMax = 500;

~kickIndex = 1;
~snareIndex = 2;
~hihatIndex = 3;
~clapIndex = 4;
~tomIndex = 5;

~commands = [~playCommand, ~sonar, ~fotoResistor, ~potentiometer1, ~potentiometer2];
~drums = [~kickIndex, ~snareIndex, ~hihatIndex, ~clapIndex, ~tomIndex];
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////---SERIAL PORT SETTING---/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SerialPort.devices;
//MISSING PORT
~port = SerialPort.new("COM3", 9600);

(
~getValues = Routine.new(
	{
		var ascii;
		var state;
		//ascii = ~commands.choose;
		//ascii.postln;
		{
			ascii = ~port.read.asAscii;
			postln(ascii);

			//Mock values
			//ascii = ~playCommand;

			//Check if command start
			switch (ascii,

				~playCommand,   {
					state = ~playCommand;
					~charArray = [ ];
					ascii = ~port.read.asAscii;
				},

				~sonar, {
					state = ~sonar;
					~charArray = [ ];
					ascii = ~port.read.asAscii;
				},

				~fotoResistor, {
					state = ~fotoResistor;
					~charArray = [ ];
					ascii = ~port.read.asAscii;
				},

				~potentiometer1, {
					state = ~potentiometer1;
					~charArray = [ ];
					ascii = ~port.read.asAscii;
				},
				~potentiometer2, {
					state = ~potentiometer2;
					~charArray = [ ];
					ascii = ~port.read.asAscii;
				}
			);


			//Check if command end
			while ({ascii.isDecDigit},
				{
					~charArray.add(ascii);
					ascii = ~port.read.asAscii;
				}
			);
			postln(~charArray);

			//Check if there are read values
			if (true/*~charArray.size > 0      ascii !== ~commandTerminator)*/,
				{
					~val1 = ~charArray.collect(_.digit).convertDigits;
					postln("ok");
					//~val1 = ~drums.choose;
					switch(state,
						~playCommand, {
							switch (~val1,

								~kickIndex, {
									var kick;
									kick = Synth(\kc, [\start, ~start_temp, \amp, ~amp_kc_temp]);
									//kick.play;
								},

								~snareIndex, {
									var snare;
									snare = Synth(\sn, [\sinfreq, ~sinfreq_temp, \ffreq, ~ffreq_sn_temp, \amp, ~amp_sn_temp ]);
									//snare.play;
								},

								~hihatIndex, {
									var hit_hat;
									hit_hat = Synth(\hh, [\ffreq, ~ffreq_hh_temp, \amp, ~amp_hh_temp])
									//hit_hat.play;
								},

								~clapIndex, {
									var clap;
									clap = Synth(\ce, [\value, ~value_temp, \amp, ~amp_clap_temp]);
									//clap_e.play;
								},

								~tomIndex, {
									var tom;
									tom = Synth(\tom, [\startPitch, ~startPitch_temp, \amp, ~amp_tom_temp]);
									//tom.play;
								}
							);
							~charArray = [ ];
						},
						~fotoResistor, {
							var value;
							~val1 = ~charArray.collect(_.digit).convertDigits;
							value = ~val1.linexp(~fotoresistorMin, ~fotoresistorMax, 0.01, 1);

							~hh_knobs[0].value = value;
							~ffreq_hh_temp = ~hh_knobs[0].value.linlin(0, 1, 100, 15000);

							~ce_knobs[0].value = value;
							~value_temp = ~ce_knobs[0].value.linlin(0, 1, 200, 9000);

							~charArray = [ ];
						},
						~potentiometer1, {
							var value;
							~val1 = ~charArray.collect(_.digit).convertDigits;
							value = ~val1.linexp(~potentiometerMin, ~potentiometerMax, 0.01, 1);

							~hh_knobs[1].value = value;
							~amp_hh_temp = ~hh_knobs[1].value.linexp(0, 1, 0.01, 3);

							~sn_knobs[1].value = value;
							~amp_sn_temp = ~sn_knobs[1].value.linexp(0, 1, 0.01, 2);

							~kc_knobs[1].value = value;
							~amp_kc_temp = ~kc_knobs[1].value.linexp(0, 1, 0.01, 2);

							~ce_knobs[1].value = value;
							~amp_clap_temp = ~ce_knobs[1].value.linexp(0, 1, 0.01, 3.5);

							~tom_knobs[1].value = value;
							~tom_knobs[1].action = ~amp_tom_temp = ~tom_knobs[1].value.linexp(0, 1, 0.01, 3);

							~charArray = [ ];
						},
						~potentiometer2, {
							var value;
							~val1 = ~charArray.collect(_.digit).convertDigits;
							value = ~val1.linexp(~kPotentiometerMin, ~kPotentiometerMax, 0.01, 1);

							~sn_knobs[0].value = value;
							~sinfreq_temp = ~sn_knobs[0].value.linexp(0, 1, 80, 1000);

							~kc_knobs[0].value = value;
							~start_temp = ~kc_knobs[0].value.linlin(0, 1, 40, 2000);

							~tom_knobs[0].value = value;
							~startPitch_temp = ~tom_knobs[0].value.linexp(0, 1, 100, 2000);

							~charArray = [ ];
						}
					)

				},{}
			);
		}.loop;

	}
).play;
)

~getValues.stop;
