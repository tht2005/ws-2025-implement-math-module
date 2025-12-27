import { type ReactNode } from 'react';
import { AMMPresentation } from './AMM';
import { BlockchainPresentation } from './Blockchain';
import { DEXFundamentalsPresentation } from './DEXFundamentals';

export interface Presentation {
  id: string;
  title: string;
  description: string;
  icon?: string;
  tags?: string[];
  slideCount: number;
  presenter?: string;
  component: () => ReactNode;
}

export const presentations: Presentation[] = [
  {
    id: 'dex-fundamentals',
    title: 'DEX Fundamentals',
    description: 'Complete workshop covering DEX concepts from AMM basics to Sui Move implementation. Interactive visualizations and code examples.',
    icon: '💱',
    tags: ['DeFi', 'Sui', 'Move', 'DEX'],
    slideCount: 26,
    presenter: 'Oliver',
    component: () => <DEXFundamentalsPresentation />,
  },
  {
    id: 'amm-basics',
    title: 'AMM Fundamentals',
    description: 'Learn the core concepts behind Automated Market Makers, including the constant product formula and how liquidity works.',
    icon: '📈',
    tags: ['DeFi', 'AMM', 'Liquidity'],
    slideCount: 8,
    presenter: 'Workshop',
    component: () => <AMMPresentation />,
  },
  {
    id: 'blockchain-101',
    title: 'Blockchain Architecture',
    description: 'Understand the fundamental architecture of blockchain systems, consensus mechanisms, and data structures.',
    icon: '🔗',
    tags: ['Blockchain', 'Architecture'],
    slideCount: 7,
    presenter: 'Workshop',
    component: () => <BlockchainPresentation />,
  },
];

export function getPresentationById(id: string): Presentation | undefined {
  return presentations.find(p => p.id === id);
}
