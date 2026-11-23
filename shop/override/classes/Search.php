<?php

class Search extends SearchCore
{
    public static function sanitize($string, $id_lang, $indexation = false, $iso_code = false, $keepHyphens = false)
    {
        if (is_string($string)) {
            // Search for the quantity and its unit together, regardless of spacing.
            // Keep the original tokens in the index for queries without a unit.
            $string = preg_replace(
                '/(?<![\p{L}\p{N}.,])(\d+(?:[.,]\d+)?)\h*'
                . '(ml|l|szt|mm|cm|m|kg|g|w|kw|v|hz|mhz|ghz|gb|tb|mah|ah|db)'
                . '(?![\p{L}\p{N}])/iu',
                $indexation ? '$0 $1$2' : '$1$2',
                $string
            ) ?? $string;
        }

        return parent::sanitize($string, $id_lang, $indexation, $iso_code, $keepHyphens);
    }
}
