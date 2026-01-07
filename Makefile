CC = gcc
CFLAGS = -Wall -O2 -ffast-math -fsingle-precision-constant -Wdouble-promotion -Wfloat-conversion
LDFLAGS = -lm

effects = flanger echo fm phaser discont
flanger_defaults = 0.6 0.6 0.6 0.6
echo_defaults = 0.3 0.3 0.3 0.3
fm_defaults = 0.25 0.25 0.5 0.5
phaser_defaults = 0.5 0.9 0.3 0.9
discont_defaults = 0.8 0.1 0.2 0.2

HEADERS = biquad.h  discont.h  echo.h  effect.h  flanger.h  fm.h  gensin.h lfo.h  phaser.h  util.h

default:
	@echo "Pick one of" $(effects)

play: output.raw
	aplay -c1 -r 48000 -f s32 output.raw

%.raw: %.mp3
	ffmpeg -y -v fatal -i $< -f s32le -ar 48000 -ac 1 $@

$(effects): input.raw convert
	./convert $@ $($@_defaults) < input.raw > output.raw
	ffmpeg -y -v fatal -f s32le -ar 48000 -ac 1 -i output.raw -f mp3 $@.mp3
	aplay -q -c1 -r 48000 -f s32 output.raw

convert.o: $(HEADERS)

convert: convert.o

output.raw: input.raw convert
	./convert echo $(echo_defaults) < input.raw > output.raw

input.raw: BassForLinus.mp3
	ffmpeg -y -v fatal -i $< -f s32le -ar 48000 -ac 1 $@

SeymourDuncan: convert
	for i in ~/Wav/Seymour\ Duncan/*; do ffmpeg -y -v fatal -i "$$i" -f s32le -ar 48000 -ac 1 pipe:1 | ./convert phaser $(phaser_defaults) | aplay -q -c1 -r 48000 -f s32; done

gensin.h: gensin
	./gensin > gensin.h

gensin: gensin.c

.PHONY: default play output.raw $(effects) SeymourDuncan
