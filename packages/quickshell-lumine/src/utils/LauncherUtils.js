.pragma library

function getAllApps(apps) {
  let arr = []
  let total = apps.length

  for (let i = 0; i < total; i++) {
    if (apps[i] && !apps[i].runInTerminal) {
      arr.push(apps[i])
    }
  }

  return arr.sort((a, b) => (a.name || "").localeCompare(b.name || ""))
}

function getFilteredApps(allApps, query) {
  if (!query || query === "") {
    return allApps
  }

  let matchedApps = []

  for (let i = 0; i < allApps.length; i++) {
    let app = allApps[i]
    let name = (app.name || "").toLowerCase()
    let genericName = (app.genericName || "").toLowerCase()
    let execString = (app.execString || "").toLowerCase()

    let score = 0

    if (name.includes(query)) score += 100
    if (genericName.includes(query)) score += 10
    if (execString.includes(query)) score += 1

    if (score > 0) {
      matchedApps.push({ app: app, score: score })
    }
  }

  matchedApps.sort((a, b) => {
    if (b.score !== a.score) {
      return b.score - a.score
    }
    return (a.app.name || "").localeCompare(b.app.name || "")
  })

  let result = []
  for (let i = 0; i < matchedApps.length; i++) {
    result.push(matchedApps[i].app)
  }

  return result
}
