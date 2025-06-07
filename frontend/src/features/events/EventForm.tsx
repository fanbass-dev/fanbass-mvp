import type { Event } from '../../types/types'

type Props = {
  event: Event
  onUpdate: (field: keyof Event, value: string | number) => void
}

export function EventForm({ event, onUpdate }: Props) {
  return (
    <div className="space-y-4">
      <div>
        <input
          type="text"
          value={event.name}
          onChange={(e) => onUpdate('name', e.target.value)}
          placeholder="Event Name"
          className="w-full text-2xl font-semibold bg-transparent border-b border-gray-600 focus:outline-none focus:border-white"
        />
      </div>

      <div className="flex flex-col">
        <label htmlFor="date" className="text-sm mb-1">Date</label>
        <input
          id="date"
          type="date"
          value={event.date}
          onChange={(e) => onUpdate('date', e.target.value)}
          className="bg-gray-800 border border-gray-600 rounded px-3 py-2"
        />
      </div>

      <div className="flex flex-col">
        <label htmlFor="location" className="text-sm mb-1">Location</label>
        <input
          id="location"
          value={event.location}
          onChange={(e) => onUpdate('location', e.target.value)}
          className="bg-gray-800 border border-gray-600 rounded px-3 py-2"
        />
      </div>

      <div className="flex flex-col">
        <label htmlFor="num_tiers" className="text-sm mb-1">Number of Lineup Tiers</label>
        <input
          id="num_tiers"
          type="number"
          min={1}
          max={10}
          value={event.num_tiers}
          onChange={(e) => onUpdate('num_tiers', Number(e.target.value))}
          className="bg-gray-800 border border-gray-600 rounded px-3 py-2"
        />
      </div>
    </div>
  )
}
