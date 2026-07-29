# RC Link Lab

Painel local para testar o tempo de ida e volta entre um dispositivo na rede
Wi-Fi e o computador servidor.

## Iniciar no Windows

```powershell
npm run dev
```

Descubra o IPv4 do computador:

```powershell
ipconfig
```

No celular, notebook ou Raspberry Pi conectado ao mesmo roteador, abra:

```text
http://IP-DO-COMPUTADOR:3000
```

Exemplo:

```text
http://192.168.1.101:3000
```

Se a página não abrir em outro dispositivo, permita o Node.js em redes privadas
no Firewall do Windows ou crie uma regra local para a porta TCP 3000.

## O que o painel mede

- RTT HTTP atual, médio, mínimo, máximo e P95
- jitter entre amostras
- perda por timeout
- percentual de pulsos abaixo da meta de 30 ms
- velocidade aproximada em uma rajada de 1 a 8 MB
- exportação CSV para comparar posições e distâncias

O painel não mede ping ICMP nem a latência final câmera-para-tela. Ele valida a
rede local antes da integração do vídeo.
