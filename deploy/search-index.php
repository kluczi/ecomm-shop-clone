<?php

require_once '/var/www/html/config/config.inc.php';

// Keep two-digit capacities, quantities, and sizes in the search index.
if (!Configuration::updateGlobalValue('PS_SEARCH_MINWORDLEN', 2) || !Search::indexation(true)) {
    fwrite(STDERR, "Could not rebuild the product search index.\n");
    exit(1);
}

echo "Product search index rebuilt.\n";
