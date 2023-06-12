
with open("RAM.hex") as f:
    binarios = f.read().splitlines()
    little_endian_binarios = [];
    for a, b, c, d in zip (*[iter(binarios)]*4):
        little_endian_binarios.append(d);
        little_endian_binarios.append(c);
        little_endian_binarios.append(b);
        little_endian_binarios.append(a);
    with open("little_endian.hex", 'w') as le:
        for bin in little_endian_binarios:
            le.write(bin + '\n')
