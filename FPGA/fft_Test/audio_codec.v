module audio_codec (
iAUD_DATA,
iAUD_LRCK,
iAUD_BCK,
GO,
RDY,
oSAMPLE
);				

parameter	SAMPLE_RATE		=	8000;		//	8		KHz
parameter	DATA_WIDTH		=	24;		//	24		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

input iAUD_DATA;
input iAUD_LRCK;
input iAUD_BCK;
output GO;
output RDY;
output[0:(DATA_WIDTH*CHANNEL_NUM)-1]oSAMPLE;

reg [0:(DATA_WIDTH*CHANNEL_NUM)-1] Sample;
reg [0:5] BIT_COUNTER; //DATA_WIDTH*CHANNEL_NUM < 64

reg mGO;
reg mRDY;


wire GO= mGO ? 1'b1:1'b0;
wire RDY= mRDY ? 1'b1:1'b0;
reg[0:(DATA_WIDTH*CHANNEL_NUM)-1]oSAMPLE;


//-- Bit Counter
always @(negedge iAUD_BCK or negedge iAUD_LRCK or posedge mGO) 
begin

if (!iAUD_LRCK)
	begin
	mGO <= 1;
	end
else
	begin
	BIT_COUNTER <= 0;
	mGO <= 0;
	mRDY <= 0;
	end

if (mGO)
	begin
	if (BIT_COUNTER==DATA_WIDTH*CHANNEL_NUM-1)
		begin
		// Transfer data to DSP
   	BIT_COUNTER <= 0;
		mGO <=0;
		mRDY <= 1;
		oSAMPLE <= Sample;
	end	
	else begin
		if (BIT_COUNTER < DATA_WIDTH*CHANNEL_NUM - 1) BIT_COUNTER<=BIT_COUNTER+1;	
	end
end
end
//----

// Get data
always@(negedge iAUD_BCK )
begin
if (mGO)
	begin
	case(BIT_COUNTER)
		6'd0 : Sample[0] <= iAUD_DATA;
		6'd1 : Sample[1] <= iAUD_DATA;
		6'd2 : Sample[2] <= iAUD_DATA;
		6'd3 : Sample[3] <= iAUD_DATA;
		6'd4 : Sample[4] <= iAUD_DATA;
		6'd5 : Sample[5] <= iAUD_DATA;
		6'd6 : Sample[6] <= iAUD_DATA;
		6'd7 : Sample[7] <= iAUD_DATA;
		6'd8 : Sample[8] <= iAUD_DATA;
		6'd9 : Sample[9] <= iAUD_DATA;
		6'd10 : Sample[10] <= iAUD_DATA;
		6'd11 : Sample[11] <= iAUD_DATA;
		6'd12 : Sample[12] <= iAUD_DATA;
		6'd13 : Sample[13] <= iAUD_DATA;
		6'd14 : Sample[14] <= iAUD_DATA;
		6'd15 : Sample[15] <= iAUD_DATA;
		6'd16 : Sample[16] <= iAUD_DATA;
		6'd17 : Sample[17] <= iAUD_DATA;
		6'd18 : Sample[18] <= iAUD_DATA;
		6'd19 : Sample[19] <= iAUD_DATA;
		6'd20 : Sample[20] <= iAUD_DATA;
		6'd21 : Sample[21] <= iAUD_DATA;
		6'd22 : Sample[22] <= iAUD_DATA;
		6'd23 : Sample[23] <= iAUD_DATA;
		6'd24 : Sample[24] <= iAUD_DATA;
		6'd25 : Sample[25] <= iAUD_DATA;
		6'd26 : Sample[26] <= iAUD_DATA;
		6'd27 : Sample[27] <= iAUD_DATA;
		6'd28 : Sample[28] <= iAUD_DATA;
		6'd29 : Sample[29] <= iAUD_DATA;
		6'd30 : Sample[30] <= iAUD_DATA;
		6'd31 :  Sample[31] <= iAUD_DATA;
		6'd32 : Sample[32] <= iAUD_DATA;
		6'd33 : Sample[33] <= iAUD_DATA;
		6'd34 : Sample[34] <= iAUD_DATA;
		6'd35 : Sample[35] <= iAUD_DATA;
		6'd36 : Sample[36] <= iAUD_DATA;
		6'd37 : Sample[37] <= iAUD_DATA;
		6'd38 : Sample[38] <= iAUD_DATA;
		6'd39 : Sample[39] <= iAUD_DATA;
		6'd40 : Sample[40] <= iAUD_DATA;
		6'd41 : Sample[41] <= iAUD_DATA;
		6'd42 : Sample[42] <= iAUD_DATA;
		6'd43 : Sample[43] <= iAUD_DATA;
		6'd44 : Sample[44] <= iAUD_DATA;
		6'd45 : Sample[45] <= iAUD_DATA;
		6'd46 : Sample[46] <= iAUD_DATA;
		6'd47 : Sample[47] <= iAUD_DATA;
		default: Sample[0] <= 0;
		endcase
end
end


endmodule