/* Módulo control unit do multiplicador karatsuba 10x10 bits */
module karatsuba_10b_cu (
  input start, clk, // sinal de inicio e clock
  output reg load_reg1, load_reg2, load_reg3, load_reg4, // loads dos registradores utilizados
  output reg sel_reg1, sel_reg2, sel_reg3, sel_reg4, // seletores de entreda dos registradores
  output reg [1:0] sel_alu_a, sel_alu_b, shamt, // seletores da alu e shift
  output reg sel_alu_b2, // seletor do seletor da alu
  output reg sel_mult_a, sel_mult_a2, sel_mult_b, sel_mult_b1, // seletor do endereço da rom lut
  output reg sub, done // sinal subtração e done
);

  // estados
  localparam IDLE = 3'b000;
  localparam S0 = 3'b001;
  localparam S1 = 3'b010;
  localparam S2 = 3'b011;
  localparam S3 = 3'b100;
  localparam S4 = 3'b101;
  localparam S5 = 3'b110;
  localparam S6 = 3'b111;

  reg [2:0] state, next;

  // atualiza o estado a cada borda de clock
  always @(posedge clk) begin
    state <= next;
  end

  always @* begin
    // mudança de estado, apenas passamos para o próximo estado
    case (state)
      IDLE: next = start ? S0 : IDLE;
      S0: next = S1;
      S1: next = S2;
      S2: next = S3;
      S3: next = S4;
      S4: next = S5;
      S5: next = S6;
      S6: next = IDLE;
      default: next = IDLE;
    endcase
  end

  always @(state) begin
    // inicializamos todas as saídas como 0
    {load_reg1, load_reg2, load_reg3, load_reg4} = 4'b0;
    {sel_reg1, sel_reg2, sel_reg3, sel_reg4} = 4'b0;
    {sel_alu_a, sel_alu_b, sel_alu_b2} = 5'b0;
    {sel_mult_a, sel_mult_a2, sel_mult_b, sel_mult_b1} = 4'b0;
    {sub, done} = 2'b0;
    shamt = 2'b00;
    case (state)
      IDLE: begin
        // caso esteja idle, esperamos pelo valor, e logo então já o gravamos nos registradores 1 e 2
        load_reg1 = 1'b1;
        load_reg2 = 1'b1;
      end
      S0: begin
        // realizamos multiplicação a1 * b1
        sel_mult_a = 1'b1;
        sel_mult_b = 1'b1;
        load_reg3 = 1'b1;
        // e soma a1 + a0 simultâneamente
        sel_reg4 = 1'b1;
        load_reg4 = 1'b1;
      end
      S1: begin
        // realizamos agora a multiplicação a0 * b0
        sel_reg1 = 1'b1;
        load_reg1 = 1'b1;
        // e a soma b1 + b1
        sel_alu_a = 2'b01;
        sel_alu_b = 2'b01;
        sel_reg2 = 1'b1;
        load_reg2 = 1'b1;
      end
      S2: begin
        sel_mult_a = 1'b1;
        sel_mult_a2 = 1'b1;
        sel_mult_b = 1'b1;
        sel_mult_b1 = 1'b1;
        load_reg4 = 1'b1;

        sel_alu_a = 2'b10;
        sel_alu_b = 2'b11;
        sel_reg2 = 1'b1;
        shamt = 2'b10;
        load_reg2 = 1'b1;
      end
      S3: begin
        sel_reg3 = 1'b1;
        sub = 1'b1;
        sel_alu_a = 2'b11;
        sel_alu_b = 2'b10;
        load_reg3 = 1'b1;
      end
      S4: begin
        sel_reg3 = 1'b1;
        sub = 1'b1;
        sel_alu_a = 2'b10;
        sel_alu_b = 2'b11;
        load_reg3 = 1'b1;
      end
      S5: begin
        sel_reg3 = 1'b1;
        sel_alu_a = 2'b10;
        sel_alu_b = 2'b11;
        sel_alu_b2 = 1'b1;
        shamt = 2'b01;
        load_reg3 = 1'b1;
      end
      S6: done = 1'b1;
      default: done = 1'b0;
    endcase
  end

endmodule