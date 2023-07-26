/* Arquivo para testar funcionalidade básica: alocar uma variável */
/* inicia o stack pointer em 1000, para realizar os testes */

long mdc_f(long a, long b);

asm(
  "addi sp,zero,1000\n\t"
  "addi fp,zero,1200\n\t"
);
int main(){
  long a, b, mdc;
  a = 64;
  b = 16; /* mdc = 16 */
  mdc = mdc_f(a, b);

  asm(
    "beq x0,x0,0\n\t"
  );
}

long mdc_f(long a, long b) {
  while (a != b) {
    if (a > b) a = a - b;
    else b = b - a;
  }
  return a;
}
