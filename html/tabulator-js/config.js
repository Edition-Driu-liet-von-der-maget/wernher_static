// holds shared config for all tabulator-js tables

var config = {
    height: 800,
    layout: "fitColumns",
    tooltips: true,
    dataLoader: true,
    rowClick: function (e, row) {
        if (e.target.closest("a, button, input, select, textarea")) {
            return;
        }

        const rowData = row.getData();
        const rowId = rowData.ID;

        if (typeof rowId === "string" && rowId.trim().length > 0) {
            window.location.href = `${rowId}.html`;
        }
    }
};
