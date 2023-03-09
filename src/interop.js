// Runs BEFORE your Elm application starts.
// The returned value is passed into `Shared.Flags`
export const flags = ({ env }) => {
  return {
    token: env.TMDB_API_TOKEN
  }
}

export const onReady = ({ app }) => {
  app.ports.outgoing.subscribe(({ tag, data }) => {
    switch (tag) {
      case 'SCROLL_ELEMENT':
        let { id, direction } = data
        let element = document.getElementById(id)
        if (element) {
          let SIZE = element.getBoundingClientRect().width / 2

          let offset =
            direction === 'left' ? -SIZE
              : direction === 'right' ? SIZE
                : 0
          element.scrollTo({
            top: 0,
            left: element.scrollLeft + offset,
            behavior: 'smooth'
          })
        }
        return
    }
  })
}