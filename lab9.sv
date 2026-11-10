`default_nettype none
// Empty top module

typedef enum logic [3:0] {
  LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
  INIT=8, OPEN=9, ALARM=10
} state_t;

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
  );
  logic [4:0] keycode;
  logic strobe;
  logic [7:0] seq;

    // Instantiate the keysync module
    keysync ks1 (
        .clk(hz100),
        .rst(reset),
        .keyin(pb[19:0]),
        .keyout(keycode),
        .keyclk(strobe)
    );

    sequence_sr sr1 (
        .clk(strobe),
        .rst(reset),
        .en(~|keycode[4:1]),
        .button(keycode[0]),
        .seq(seq)
    );

    // Testing assignments (to be commented out when starting the lab)
    assign right[0] = strobe;        // only for use for testing lab assignment, comment out when starting the lab
    assign right[5:1] = keycode;     // only for use for testing lab assignment, comment out when starting the lab
endmodule

module display (
    input logic hzX,
    input logic [3:0] state,
    output logic [63:0] ss,
    output logic red, green, blue
    );
    always_comb begin
    case(state)
        ALARM: begin
            // what happens when state == ALARM?
        end
        LS0: begin
            assign ss = 64'b01101101_01111001_00111001_00111110_01010000_01111001;
        end
        LS1 : begin
            
        end, 
        LS2: begin
            // you can also combine multiple states
        end
        LS3: begin
            // you can also combine multiple states
        end
        LS4 : begin
            // you can also combine multiple states
        end
        LS5: begin
            // you can also combine multiple states
        end 
        LS6: begin
            // you can also combine multiple states
        end 
        LS7: begin
        end
        default: begin
            // what happens when state is none of the above?
            // best to have this to catch any errors - set all outputs to zero.
        end
    endcase
end
endmodule

module fsm (
    input logic clk,
    input logic rst,
    input logic [4:0] keyout,
    input logic [7:0] seq,
    output logic [3:0] state
    );
    state_t lockstate, n_lockstate;
    logic M, R;
    assign state = lockstate;
    assign M = (keyout[0] ~^ seq[~lockstate[2:0]]) & ~|keyout[4:1];
    assign R = keyout == 5'b10000 ? 1'b1 : 1'b0;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lockstate <= INIT;
        end else begin
            lockstate <= n_lockstate;
        end
    end
    always_comb begin
        casez({lockstate, M, R})
            {INIT, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS0, 1'b1, 1'b0}: n_lockstate = LS1;
            {LS1, 1'b1, 1'b0}: n_lockstate = LS2;
            {LS2, 1'b1, 1'b0}: n_lockstate = LS3;
            {LS3, 1'b1, 1'b0}: n_lockstate = LS4;
            {LS4, 1'b1, 1'b0}: n_lockstate = LS5;
            {LS5, 1'b1, 1'b0}: n_lockstate = LS6;
            {LS6, 1'b1, 1'b0}: n_lockstate = LS7;
            {LS7, 1'b1, 1'b0}: n_lockstate = OPEN;
            {OPEN, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS0, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS1, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS2, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS3, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS4, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS5, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS6, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS7, 1'b0, 1'b0}: n_lockstate = ALARM;
            {LS1, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS2, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS3, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS4, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS5, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS6, 1'b?, 1'b1}: n_lockstate = LS0;
            {LS7, 1'b?, 1'b1}: n_lockstate = LS0;
            default: n_lockstate = lockstate;
        endcase
    end
endmodule

module sequence_sr (
    input logic clk,
    input logic rst,
    input logic en,
    input logic button,
    output logic [7:0] seq
    );
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            seq <= 8'b00000000;
        end else if (en) begin
            seq <= {seq[6:0], button};
        end
    end
endmodule

module clock_psc (
    input logic clk,
    input logic rst,
    input logic [7:0] lim,
    output logic hzX
    );
    logic [7:0] counter;
    logic hzX_int;
    assign hzX = (lim != 8'b0) ? hzX_int : 1'b0;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hzX_int <= 1'b0;
            counter <= 8'b0;
        end else if (counter < lim) begin
                counter <= counter + 8'b1;
        end else if (counter >= lim) begin
            counter <= 8'b0;
            hzX_int <= ~hzX_int;
        end
    end
endmodule

module keysync (
    input logic clk,
    input logic rst,
    input logic [19:0] keyin,
    output logic [4:0] keyout,
    output logic keyclk
    );
    logic [1:0] key_sync;
    logic keypressed;
    assign keypressed = |keyin;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            key_sync <= 2'b00;
            keyout <= 5'b0;
            keyclk <= 1'b0;
        end else begin
            key_sync[0] <= keypressed;
            key_sync[1] <= key_sync[0];
        end
    end
    always_comb begin
        keyclk = key_sync[0] & ~key_sync[1];
    end
endmodule
