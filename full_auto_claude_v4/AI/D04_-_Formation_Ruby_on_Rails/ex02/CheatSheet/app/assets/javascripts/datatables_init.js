$(document).ready(function() {
  $('#cheatsheet-table').DataTable({
    pageLength: 25,
    language: {
      search: "Search:",
      lengthMenu: "Show _MENU_ entries",
      info: "Showing _START_ to _END_ of _TOTAL_ entries",
      paginate: {
        first: "First",
        last: "Last",
        next: "Next",
        previous: "Previous"
      }
    }
  });
});
