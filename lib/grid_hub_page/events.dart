part of grid_hub_page;

class Events extends Object with RepoEvents {

    Events(Actions actions) {
        wireRepoEvents(actions);
    }

}
