# MODELAGEM ANTUNES — espaço 3D A3

Espaço compartilhado para receber projetos `.blend` e modelos `.glb`, com até quatro visualizadores 3D independentes. A biblioteca é comum a todos os navegadores conectados: arquivos novos e versões substituídas são anunciados por WebSocket e aparecem em tempo real.

O repositório `modelagem-antunes` contém o código do site, o frontend e as configurações para publicação.

## Login e registro

A biblioteca agora exige uma conta. Ao abrir o site pela primeira vez, use o botão **Criar uma conta**; o cadastro e o login usam nome e senha, sem exigir e-mail. O cadastro está limitado a 10 contas e cada uma usa um modelo único da lista de aviões. Após cadastrar, a tela volta ao login com o nome preenchido. Os últimos cinco nomes usados ficam sugeridos nesse navegador; as contas são armazenadas em `data/users.json`, e a sessão é protegida por cookie HTTP-only. Configure `AUTH_SECRET` em produção com um valor aleatório e longo para assinar as sessões; defina `MODEL_HTTPS_ONLY=true` quando o site estiver publicado por HTTPS.

## Iniciar no Windows

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m uvicorn app:app --reload
```

Abra `http://127.0.0.1:8000`. O primeiro uso precisa de internet para instalar as dependências e carregar o Three.js e as fontes da interface.

Para gerar prévias de arquivos `.blend` sem instalar Blender no sistema, execute uma vez:

```powershell
.\setup_blender.ps1
```

O script baixa o Blender portátil 5.2.2 da fonte oficial, verifica o SHA-256 e o guarda em `%LOCALAPPDATA%`. O servidor usa essa versão automaticamente para converter os projetos em prévias `.glb`.

## Enviar ou atualizar modelos

Envie um projeto `.blend` (inclusive comprimido pelo Blender ou backup `.blend1`) ou um modelo `.glb` pelo botão **Enviar arquivo**, arraste-o para o navegador, ou coloque-o na pasta `models/`. Também é possível clicar em **GitHub** e informar o link de um arquivo público `.blend`, `.blend1` ou `.glb` (link `github.com/.../blob/...` ou `raw.githubusercontent.com`). O site aceita até 250 MB por arquivo. Um arquivo com o mesmo nome substitui a versão anterior e os participantes conectados recebem a atualização.

Links importados do GitHub ficam monitorados no servidor. O arquivo remoto é conferido a cada 1 segundo; quando muda, a cópia local e os visores conectados são atualizados automaticamente. Se alguém enviar manualmente um arquivo com o mesmo nome, o vínculo com o GitHub é removido.

Quem acessa o site não precisa ter Blender instalado: o servidor converte cada `.blend` em uma prévia `.glb` e mantém o original na biblioteca. No Windows local, `setup_blender.ps1` prepara o conversor portátil; o Docker de produção já inclui o Blender. A conversão empacota as imagens disponíveis no projeto. Imagens externas ausentes e materiais ou nós incompatíveis com glTF podem não aparecer; para melhores resultados, empacote as texturas no projeto e use materiais Principled BSDF.

Cada painel tem seleção e câmera próprias. Escolha um arquivo no menu e clique em **Carregar** para exibi-lo; o botão de tela cheia expande aquele visualizador. Clicar em um item da biblioteca seleciona-o no primeiro painel vazio. Os quatro painéis podem exibir modelos diferentes.

## Publicar com HTTPS

O GitHub guarda o código; o Render executa o Docker, Python e Blender. O código está no repositório `antonioassuncaoneto20-ctrl/modelagem-antunes`. No Render, escolha **New > Blueprint** e conecte esse repositório. O Blueprint usa o plano gratuito e publica o serviço em uma URL `https://modelagem-antunes.onrender.com` (se o nome estiver disponível), com novos deploys após atualizações no GitHub.

No plano gratuito, o serviço pode dormir após 15 minutos sem tráfego e levar cerca de um minuto para voltar. O armazenamento é temporário: modelos enviados e arquivos importados do GitHub podem desaparecer quando o serviço dormir, reiniciar ou receber um novo deploy. Para usá-los novamente, importe os modelos do GitHub ou envie-os de novo. Os limites mensais gratuitos do Render também se aplicam. O `.dockerignore` exclui `models/` e `data/`.

O site exige login para abrir a biblioteca e acessar ou modificar os modelos. O repositório pode ser privado ou público, mas os arquivos da biblioteca não ficam disponíveis sem uma conta criada no servidor.

## Acesso dos amigos

Por padrão, o servidor só aceita conexões do próprio computador. Para amigos na mesma rede Wi-Fi, inicie com `python -m uvicorn app:app --host 0.0.0.0 --port 8000` e compartilhe o endereço IP local do computador com a porta `8000`, por exemplo `http://192.168.0.10:8000`. O firewall do Windows pode pedir autorização para conexões na rede privada.

Para acesso fora da rede local, use a publicação HTTPS acima. Links GitHub e sincronização ao vivo continuam funcionando no serviço hospedado.
