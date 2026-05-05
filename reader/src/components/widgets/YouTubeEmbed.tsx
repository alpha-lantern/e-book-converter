import React, { useState } from 'react';
import { Play } from 'lucide-react';
import { snakeToCamel } from '../../utils/styleUtils';
import type { CodexStyle } from '../../types/codex';

interface YouTubeEmbedProps {
  videoId: string;
  title?: string;
  style?: CodexStyle;
}

const YouTubeEmbed = ({ videoId, title = 'YouTube Video', style }: YouTubeEmbedProps) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const camelStyle = snakeToCamel(style);

  const thumbnailUrl = `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`;
  const embedUrl = `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0`;

  if (isLoaded) {
    return (
      <div
        className="relative w-full aspect-video rounded-xl overflow-hidden shadow-lg my-8"
        style={camelStyle}
      >
        <iframe
          src={embedUrl}
          title={title}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          allowFullScreen
          className="absolute inset-0 w-full h-full border-0"
        />
      </div>
    );
  }

  return (
    <div
      className="relative w-full aspect-video rounded-xl overflow-hidden shadow-lg my-8 group cursor-pointer bg-gray-100"
      style={camelStyle}
      onClick={() => setIsLoaded(true)}
      role="button"
      aria-label={`Play video: ${title}`}
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          setIsLoaded(true);
        }
      }}
    >
      <img
        src={thumbnailUrl}
        alt={title}
        onError={(e) => {
          (e.target as HTMLImageElement).src = `https://i.ytimg.com/vi/${videoId}/mqdefault.jpg`;
        }}
        className="absolute inset-0 w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
        loading="lazy"
      />
      <div className="absolute inset-0 flex items-center justify-center bg-black/10 group-hover:bg-black/20 transition-colors duration-300">
        <div className="w-16 h-16 md:w-20 md:h-20 bg-red-600 rounded-full flex items-center justify-center shadow-2xl transition-transform duration-300 group-hover:scale-110">
          <Play className="w-8 h-8 md:w-10 md:h-10 text-white fill-current ml-1" />
        </div>
      </div>
      <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/60 to-transparent">
        <span className="text-white font-medium truncate block">{title}</span>
      </div>
    </div>
  );
};

export default YouTubeEmbed;
