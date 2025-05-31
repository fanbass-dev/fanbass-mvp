import type { Event } from '../../types/types'

type Props = {
  event: Event
  onUpdate: (field: keyof Event, value: string | number) => void
}

export function EventForm({ event, onUpdate }: Props) {
  return (
    <>
      <h2>
        <input
          value={event.name}
          onChange={(e) => onUpdate('name', e.target.value)}
          placeholder="Event Name"
          style={{ fontSize: '1.5rem', width: '100%' }}
        />
      </h2>
      <label>
        Date:
        <input
          type="date"
          value={event.date}
          onChange={(e) => onUpdate('date', e.target.value)}
        />
      </label>
      <br />
      <label>
        Location:
        <input
          value={event.location}
          onChange={(e) => onUpdate('location', e.target.value)}
        />
      </label>
      <br />
      <label>
        Number of Tiers:
        <input
          type="number"
          min={1}
          max={10}
          value={event.num_tiers}
          onChange={(e) => onUpdate('num_tiers', Number(e.target.value))}
        />
      </label>
    </>
  )
}
