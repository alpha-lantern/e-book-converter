export interface CodexStyle {
  font_size?: number;
  font_weight?: string;
  line_height?: number;
  color?: string;
  text_align?: 'left' | 'center' | 'right' | 'justify';
  margin_top?: number;
  margin_bottom?: number;
  font_family?: string;
  text_decoration?: string;
  font_style?: string;
}

export type CodexBlockType = 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'p' | 'image' | 'widget';

export interface CodexBlock {
  type: CodexBlockType;
  content?: string;
  src?: string;
  alt?: string;
  level?: 1 | 2 | 3 | 4 | 5 | 6;
  style?: CodexStyle;
  properties?: Record<string, unknown>;
  aspect_ratio?: number;
}

export interface CodexSEO {
  title?: string;
  description?: string;
  keywords?: string[];
}

export interface CodexMeta {
  title: string;
  description: string;
  author?: string;
  date?: string;
  seo?: CodexSEO;
}

export interface CodexManifest {
  version: string;
  meta: CodexMeta;
  blocks: CodexBlock[];
}
