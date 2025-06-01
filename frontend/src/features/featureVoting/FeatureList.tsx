// src/features/featureVoting/FeatureList.tsx

import { FeatureItem } from './FeatureItem'
import type { Feature } from './types'

type Props = {
  features: Feature[]
  onVote: (id: string) => void
}

export function FeatureList({ features, onVote }: Props) {
  console.log('Rendering features:', features) // 👈 add this
  return (
    <div>
      {features.map((feature) => (
        <FeatureItem key={feature.id} feature={feature} onVote={onVote} />
      ))}
    </div>
  )
}

