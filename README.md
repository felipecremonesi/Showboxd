# Showboxd

Um aplicativo Flutter para registrar, avaliar e compartilhar experiências de shows e eventos musicais. O app permite cadastrar eventos, adicionar fotos, ver detalhes, favoritar, avaliar artistas

<p align="center">
<img src="/imagens/login.jpeg" width="240" height="480">
  &nbsp;&nbsp;&nbsp;
<img src="/imagens/inicio.jpeg" width="240" height="480">
  &nbsp;&nbsp;&nbsp;
<img src="/imagens/festivalinicio.jpeg" width="240" height="480">
</p>
  
**Funcionalidades**

📌 Cadastro de shows e eventos com:
- Nome do artista
- Local, data e preço
- Setlist e artista de abertura
- Campos personalizados como “música favorita”
- Upload e galeria de fotos por evento
- Nos shows certas informações são privadas para o dono como Preço, Setor, Música Favorita, Edição e exclusão das Informações do show
  
❤️ Sistema de wishlist (favoritar shows)

⭐ Avaliação de presença de palco e comentários

<p align="center">
<img src="/imagens/avaliacao.jpeg" width="240" height="480">
</p>

👤 Autenticação de usuários (Google/Firebase)

🎉 Registro de Festivais com um grupo de artistas

<p align="center">
<img src="/imagens/showregistro1.jpeg" width="240" height="480">
  &nbsp;&nbsp;&nbsp;
<img src="/imagens/showregistro2.jpeg" width="240" height="480">
  &nbsp;&nbsp;&nbsp;
<img src="/imagens/festivalregistro.jpeg" width="240" height="480">
</p>

**Permissões**

Algumas permissões serão necessárias para o funcionamento da aplicação como no AndroidManifest.xml:

- android.permission.INTERNET
- android.permission.WRITE_EXTERNAL_STORAGE
- android.permission.READ_EXTERNAL_STORAGE

Além de dentro da tag *application* o uso de android:requestLegacyExternalStorage="true"

**Firebase**

O projeto utiliza os serviços do **Google Firebase**, especificamente **Realtime Database** e **Storage** para armazenar informações dos shows e também as fotos enviadas. Para que o aplicativo funcione corretamente, é necessário configurar o Firebase no seu próprio projeto e incluir os arquivos de configuração correspondentes (como o **google-services.json** no Android). Esses arquivos não estão incluídos neste repositório e devem ser baixados diretamente do [console do Firebase](https://console.firebase.google.com/) após a criação e configuração do seu projeto.
