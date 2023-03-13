// Runs BEFORE your Elm application starts.
// The returned value is passed into `Shared.Flags`
export const flags = ({ env }) => {
  return {
    token: env.TMDB_API_TOKEN
  }
}

export const onReady = ({ app }) => {

  // Scroll to top when navigating from one page to another
  if ('navigation' in window) {
    window.navigation.onnavigate = (event) => {
      let oldUrl = new URL(window.location.href)
      let newUrl = new URL(event.destination.url)
      if (oldUrl.pathname !== newUrl.pathname) {
        window.requestAnimationFrame(() => {
          let page = document.getElementById('page')
          if (page) {
            page.scrollTo(0, 0)
          } else {
            window.scrollTo(0, 0)
          }
        })
      }
    }
  }

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