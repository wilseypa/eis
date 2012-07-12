#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Top Block
# Generated: Tue May 29 01:48:58 2012
##################################################

from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import window
from gnuradio.eng_option import eng_option
from gnuradio.gr import firdes
from gnuradio.wxgui import fftsink2
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import wx

class top_block(grc_wxgui.top_block_gui):

	def __init__(self):
		grc_wxgui.top_block_gui.__init__(self, title="Top Block")
		_icon_path = "/usr/share/icons/hicolor/32x32/apps/gnuradio-grc.png"
		self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

		##################################################
		# Variables
		##################################################
		self.samp_rate = samp_rate = 32000

		##################################################
		# Blocks
		##################################################
		self.wxgui_fftsink2_0 = fftsink2.fft_sink_f(
			self.GetWin(),
			baseband_freq=0,
			y_per_div=10,
			y_divs=10,
			ref_level=0,
			ref_scale=2.0,
			sample_rate=samp_rate,
			fft_size=1024,
			fft_rate=15,
			average=False,
			avg_alpha=None,
			title="FFT Plot",
			peak_hold=False,
		)
		self.Add(self.wxgui_fftsink2_0.win)
		self.gr_throttle_0 = gr.throttle(gr.sizeof_float*1, samp_rate)
		self.gr_sub_xx_0 = gr.sub_ff(1)
		self.gr_sig_source_x_0 = gr.sig_source_f(samp_rate, gr.GR_TRI_WAVE, 1, 5, 5)
		self.gr_noise_source_x_0 = gr.noise_source_f(gr.GR_GAUSSIAN, 1, 0)
		self.gr_moving_average_xx_0 = gr.moving_average_ff(30, 1, 4000)
		self.gr_add_xx_0 = gr.add_vff(1)

		##################################################
		# Connections
		##################################################
		self.connect((self.gr_noise_source_x_0, 0), (self.gr_add_xx_0, 1))
		self.connect((self.gr_sig_source_x_0, 0), (self.gr_add_xx_0, 0))
		self.connect((self.gr_add_xx_0, 0), (self.gr_moving_average_xx_0, 0))
		self.connect((self.gr_moving_average_xx_0, 0), (self.gr_sub_xx_0, 0))
		self.connect((self.gr_add_xx_0, 0), (self.gr_sub_xx_0, 1))
		self.connect((self.gr_sub_xx_0, 0), (self.gr_throttle_0, 0))
		self.connect((self.gr_throttle_0, 0), (self.wxgui_fftsink2_0, 0))

	def get_samp_rate(self):
		return self.samp_rate

	def set_samp_rate(self, samp_rate):
		self.samp_rate = samp_rate
		self.gr_sig_source_x_0.set_sampling_freq(self.samp_rate)
		self.wxgui_fftsink2_0.set_sample_rate(self.samp_rate)

if __name__ == '__main__':
	parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
	(options, args) = parser.parse_args()
	tb = top_block()
	tb.Run(True)

