// Perfis oficiais da marca. Para ligar um perfil novo (ex.: TikTok), basta preencher o link aqui:
// ele aparece nos rodapés, no fim dos artigos e no JSON-LD da home (sameAs) sozinho.
export interface SocialProfile {
  id: 'instagram' | 'tiktok' | 'pinterest'
  label: string
  url: string
}

export const SOCIAL_LINKS: SocialProfile[] = [
  { id: 'instagram', label: 'Instagram', url: 'https://www.instagram.com/patty.scancrush' },
  { id: 'tiktok', label: 'TikTok', url: '' },
  { id: 'pinterest', label: 'Pinterest', url: 'https://br.pinterest.com/scancrush/' },
]

export const activeSocialLinks = () => SOCIAL_LINKS.filter((s) => s.url)
