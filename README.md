# 🎨 Color C

**Color C** é um app Flutter feito pensando em ajudar pessoas daltônicas a identificarem e explorarem cores no mundo real.

A proposta é simples: tire uma foto ou selecione uma imagem, toque em um ponto e descubra a cor exata — com nome, código hexadecimal, descrição perceptual e paletas de cores complementares.

> _"Color C" é um trocadilho de "Color See", o oposto de "Colorblind"!_

# 🧪 Funcionalidades

- 📷 **Captura via câmera** ou **seleção da galeria**
- 🎨 **Extração automática de cores dominantes** — aba "Auto" na tela de preview extrai as 8 cores mais presentes na imagem em segundo plano, sem travar a UI
- 🖱️ **Toque em qualquer ponto da imagem** para detectar a cor exata
- 🟩 **Pré-visualização** com cor de fundo, hexadecimal e nome da cor
- 🌐 Integração com [The Color API](https://www.thecolorapi.com/) para identificação semântica da cor
- 🎨 **Adaptação automática do tema** do app com base na cor detectada
- 🎨 **Paletas complementares** via API (monocromática, análoga, complementar, triádica, quádrupla) com fallback local
- 🧠 **Descrição perceptual da cor** ("parece roxo", "quente · vívido · médio") — acessível para daltônicos
- 📋 **Copiar hexadecimal** com um toque no código da cor
- 💾 **Salvar paletas favoritas** com persistência local (até 50 paletas) e acesso rápido pela tela inicial
- 📤 **Compartilhar paletas** — gera uma imagem 1:1 com a paleta e envia via share sheet nativo, incluindo link para The Color API e Google Play
- 🔔 **Feedback háptico** ao detectar uma cor, ao carregar o nome via API e ao exibir paletas complementares
- 🌐 **Confiabilidade de rede**: timeout, estados de loading, retry automático e notificações de erro

# 🛠️ Tecnologias

- **Flutter** / **Material 3**
- **Provider** para gerenciamento de estado
- **shared_preferences** para persistência local de paletas
- **share_plus** para compartilhamento nativo de imagens
- **Image Picker** + **Photo View**
- **HTTP** para integração com APIs externas

# 🚀 Como rodar localmente

1. Clone o projeto:

   ```
   git clone https://github.com/LSoares02/color-c.git
   cd color-c
   ```

2. Instale as dependências:

   ```
   flutter pub get
   ```

3. Rode em um emulador ou dispositivo físico:

   ```
   flutter run
   ```

# 📱 Plataformas

✅ Android

✅ iOS

> 🧪 Testado em: Android API 35 (emulador) e iOS 18 (iPhone 12 mini)

> _"See the unseen. Decode the colors." — Color C_
