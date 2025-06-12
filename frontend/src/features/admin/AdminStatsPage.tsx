import React from 'react'

export default function AdminStatsPage() {
  // Placeholder data
  const stats = {
    totalUsers: 1234,
    signInsToday: 56,
    signInsThisWeek: 312,
    activeUsers: 789,
    // Add more as needed
  }

  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <h1 className="text-xl font-semibold mb-4">Platform Statistics</h1>
      <div className="grid grid-cols-2 gap-4 mb-8">
        <div className="bg-gray-800 rounded-lg px-4 py-4 flex flex-col items-center justify-center text-center">
          <p className="text-2xl font-bold text-brand">{stats.totalUsers}</p>
          <h2 className="text-base text-gray-300">Total Users</h2>
        </div>
        <div className="bg-gray-800 rounded-lg px-4 py-4 flex flex-col items-center justify-center text-center">
          <p className="text-2xl font-bold text-brand">{stats.signInsToday}</p>
          <h2 className="text-base text-gray-300">Sign-ins Today</h2>
        </div>
        <div className="bg-gray-800 rounded-lg px-4 py-4 flex flex-col items-center justify-center text-center">
          <p className="text-2xl font-bold text-brand">{stats.signInsThisWeek}</p>
          <h2 className="text-base text-gray-300">Sign-ins This Week</h2>
        </div>
        <div className="bg-gray-800 rounded-lg px-4 py-4 flex flex-col items-center justify-center text-center">
          <p className="text-2xl font-bold text-brand">{stats.activeUsers}</p>
          <h2 className="text-base text-gray-300">Active Users</h2>
        </div>
      </div>
      <div className="text-gray-400 text-sm">(This is placeholder data. Real stats will be wired soon.)</div>
    </div>
  )
} 