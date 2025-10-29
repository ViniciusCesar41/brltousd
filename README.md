BRL → USD Flutter (minimal)

Arquivos:
- lib/main.dart : código-fonte do app
- pubspec.yaml   : dependências

Passo a passo para executar (resumido):
1) Instale Flutter: https://flutter.dev/docs/get-started/install
2) No terminal, crie um novo projeto Flutter ou use este:
   flutter create brl_to_usd_flutter
3) Substitua o conteúdo de lib/main.dart pelo arquivo fornecido aqui.
4) Substitua pubspec.yaml pelo fornecido e rode:
   flutter pub get
5) Execute em emulador ou dispositivo:
   flutter run

Descrição do app:
- Insira valor em BRL.
- Insira cotação (USD por 1 BRL). Exemplo: 0.19
- Toque em "Converter" para ver o valor em USD.

Observações:
- Cotação padrão é apenas exemplo. Para cotação real atualizada use uma API externa.
- Se quiser que eu busque a cotação em tempo real, diga e eu adiciono requisição HTTP.