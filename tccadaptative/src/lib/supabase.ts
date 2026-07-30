import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  const message =
    'Configuração do Supabase ausente. Crie um arquivo .env na raiz do projeto ' +
    'com VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY (veja .env.example) e reinicie o servidor.';

  // Mostra o erro na própria tela em vez de deixar a página em branco
  document.body.innerHTML = `
    <div style="font-family: sans-serif; max-width: 640px; margin: 80px auto; padding: 24px; color: #b91c1c; background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px;">
      <h1 style="font-size: 18px; margin-bottom: 8px;">Erro de configuração</h1>
      <p>${message}</p>
    </div>`;

  throw new Error(message);
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const supabase = createClient(supabaseUrl, supabaseAnonKey) as any;
