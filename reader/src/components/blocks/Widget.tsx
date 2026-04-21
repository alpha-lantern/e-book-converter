import React from 'react';
import { snakeToCamel } from '../../utils/styleUtils';
import type { CodexStyle } from '../../types/codex';

interface WidgetProps {
  type: string;
  properties?: Record<string, unknown>;
  style?: CodexStyle;
}

const Widget: React.FC<WidgetProps> = ({ type, properties, style }) => {
  const camelStyle = snakeToCamel(style);

  return (
    <div
      className="p-8 border-2 border-dashed border-purple-200 rounded-xl bg-purple-50/50 flex flex-col items-center justify-center text-center space-y-2 my-8"
      style={camelStyle}
    >
      <div className="text-purple-500 font-medium">Interactive Widget Placeholder</div>
      <div className="text-sm text-gray-500 max-w-sm">
        This is an interactive widget powered by React.
        {type && <span> Type: <code className="bg-purple-100 px-1 rounded">{type}</code></span>}
      </div>
      {properties && Object.keys(properties).length > 0 && (
        <div className="mt-4 text-xs text-left w-full bg-white p-2 rounded border border-purple-100">
          <div className="font-bold mb-1">Properties:</div>
          <pre>{JSON.stringify(properties, null, 2)}</pre>
        </div>
      )}
    </div>
  );
};

export default Widget;
