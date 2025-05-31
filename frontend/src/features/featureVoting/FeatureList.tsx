// src/features/featureVoting/FeatureList.tsx

import { FeatureItem } from './FeatureItem'
import type { Feature } from './types'

type Props = {
  features: Feature[]
  onVote: (id: string) => void
}

export function FeatureList({ features, onVote }: Props) {
  return (
    <div>
      {features.map((feature) => (
        <FeatureItem key={feature.id} feature={feature} onVote={onVote} />
      ))}
    </div>
  )
}
