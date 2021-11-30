<?php
/**
 * LiveImage, library for workin with images.
 * (c) Alex Kachayev, http://www.kachayev.ru
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * See http://www.gnu.org/copyleft/lesser.html
 *
 * LiveImage:
 * Main functions for resize, crop and stylize your picture.
 *
 * @author  Alex Kachayev   
 * @version 1.2
 * @package LiveImage
 * @todo: Rewrite to use Imagick only
 * @todo Merge into engine/modules/image/Image.class.php
 */

class LiveImage {
	/**
	 * Image object handler
	 *
	 * @var object
	 */
	protected $image=null;
	/**
	 * @var bool
	 */
	protected $truecolor=true;
	/**
	 * @var int
	 */
	protected $width=0;
	/**
	 * @var int
	 */
	protected $height=0;
	/**
	 * Color param (RGB code)
	 * 
	 * @var array
	 */
	protected $color=array('r'=>255,'g'=>255,'b'=>255); 
	/**
	 * Pixel font size
	 * 
	 * @var int
	 */	
	protected $font_size=20;
	/**
	 * Font name for making image labels.
	 * For saving true type fonts use /font directory.
	 * 
	 * @var string
	 */
	protected $font='';
	/**
	 * Resizing scale
	 * 
	 * @var int
	 */
	protected $scale = 1;
	/**
	 * Format of image file\object
	 *
	 * @var string
	 */
	protected $format='';
	/**
	 * Quality of output JPG image
	 * 
	 * @var int
	 */
	protected $jpg_quality = 99;
	/**
	 * Error texts
	 *
	 * @var array
	 */
	protected $error_messages = array(
		1  => 'Can`t create image',
		2  => 'No font was given',
		3  => 'No file was given',
		4  => 'Can`t open image from file',
		5  => 'Unknown file format given',
		6  => 'Failed image resource given'
	);
	/**
	 * Last error text
	 *
	 * @var strng
	 */
	protected $last_err_text='';
	/**
	 * Last error code
	 *
	 * @var int
	 */
	protected $last_err_num=0;
    /**
     * ImageMagick instance
     */
    private $magic;
    /**
     * MIME database
     */
    private $fileInfo;
    /**
     * Разрешенные типы изображений
     */
    const aAllowedMimes = [
        "image/gif" => "gif",
        "image/png" => "png",
        "image/x-png" => "png",
        "image/jpg" => "jpg",
        "image/jpeg" => "jpg",
        "image/pjpeg" => "jpg",
        "image/webp" => "webp"
    ];

	/**
	 * Создает объект изображения из переданного файла
	 *
	 * @param string $sFile
	 * @return bool|mixed
	 */
	public function __construct($sFile) {
        $this->fileInfo = finfo_open(FILEINFO_MIME_TYPE);
        $sMime = finfo_file($this->fileInfo, $sFile);
        if (!array_key_exists($sMime, $this::aAllowedMimes)) {
            $this->set_last_error(5);
            return false;
        }
        $this->format = $this::aAllowedMimes[$sMime];

        $img_max_width = Config::Get('view.processing.img_max_width');
        $img_max_height = Config::Get('view.processing.img_max_height');
        $imageInfo = getimagesize($sFile);
        if (
            (int)$imageInfo[0] > $img_max_width ||
            (int)$imageInfo[1] > $img_max_height
        ) {
            $this->set_last_error(4);
            return false;
        }

        $this->magic = new Imagick();
		try {
			$this->magic->readImage($sFile);
		} catch (Exception $e) {
			$this->set_last_error(4);
			return false;
		}

		if(!$sFile) {
			$this->set_last_error(3);
			return false;
		}

        $iFileLength = (int) $this->magic->getImageLength();
        if(!$iFileLength) {
            $this->set_last_error(3);
            return false;
        }

		$this->image=$this->magic;
		$this->width=(int)$this->magic->getImageWidth();
		$this->height=(int)$this->magic->getImageHeight();
		$this->truecolor=true;
		
		return true;
	}
    function __destruct()
    {
        if ($this->fileInfo){
            finfo_close($this->fileInfo);
        }
        if ($this->magic){
            $this->magic->clear();
        }
    }

    /**
	 * Resize handle image
	 *
	 * @param  int   $width
	 * @param  int   $height
	 * @param  int   $src_resize
	 * @param  int   $scale
	 * @return mixed
	 */
	public function resize($width=null,$height=null,$scale=false,$alfa=true) {
		$this->clear_error();
		/**
		 * Если не указана новая высота, значит применяем масштабирование.
		 * Если не указана ширина, то "забираем" ширину исходного.
		 */
		$height=(!$height)?1:$height;
		$width=(!$width)?$this->width:$width;
		
		if( $scale ){
			$scale_x = $this->width / $width;
			$scale_y = $this->height / $height;
			$this->scale = min($scale_x, $scale_y);
						
			$width  = round($this->width / $this->scale);
			$height = round($this->height / $this->scale);
		}

		$this->image->resizeImage($width, $height, imagick::FILTER_LANCZOS, 1);
		return true;
	}

	/**
	 * Crop image
	 *
	 * @param  int   $width
	 * @param  int   $height
	 * @param  int   $start_width
	 * @param  int   $start_height
	 * @return mixed
	 */
	public function crop($width, $height, $start_width, $start_height) {	
		$this->image->cropImage($width, $height, $start_width, $start_height);
		return true;		
	}
	
	/**
	 * Return image object
	 *
	 * @return mixed
	 */
	public function get_image() {
		return $this->image;
	}
	/**
	 * Add new image object to current handler
	 *
	 * @param  resource $image_res
	 * @return bool
	 * 
	 * @todo   Find format of given image
	 */
	public function set_image($image_res) {
		if (intval(@imagesx($image_res)) > 0) {
			$this->image=$image_res;
			$this->width=imagesx($image_res);
			$this->height=imagesy($image_res);
			return true;		
		}
		
		$this->set_last_error(6);
		return false;
	}
	
	/**
	 * Return image params
	 *
	 * @param  string $key
	 * @return array
	 */
	public function get_image_params($key=null) {
		$params=array(
			'width'     => $this->width, 
			'height'    => $this->height, 
			'truecolor' => $this->truecolor, 
			'format'    => $this->format
		);
		if(is_null($key)) {
			return $params;
		}
		
		if(array_key_exists($key,$params)){
			return $params[$key];
		}
		
		return false;
	}

	/**
	 * Setter for font params
	 *
	 * @param string $font_size
	 * @param int    $font_angle
	 * @param string $name
	 */
	public function set_font($font_size=20,$font_angle=0,$name='') {
		if($name) {
			$this->font=$name;
		}

		$this->font_size=$font_size;
		$this->font_angle=$font_angle;
	}

	/**
	 * Setter for color
	 *
	 * @param  int  $r
	 * @param  int  $g
	 * @param  int  $b
	 * @param  bool $transparency
	 * 
	 * @return mixed	 
	 */
	public function set_color($r=255,$g=255,$b=255,$transparency=false) {
		$this->color=array('r'=>$r,'g'=>$g,'b'=>$b);

		if(!$transparency) {
	 		$this->color['locate']=imagecolorallocate($this->image,$this->color['r'],$this->color['g'],$this->color['b']);
		} else {
			$this->color['locate']=imagecolorallocatealpha($this->image,$this->color['r'],$this->color['g'],$this->color['b'],$transparency);			
		}

		return $this->color['locate'];
	}

	/**
	 * Set JPG output quality
	 *
	 * @param  int $quality
	 * @return null
	 */
	public function set_jpg_quality($quality=null) {
		$this->jpg_quality = $quality;
	}

	/**
	 * Make image output in file or in browser.
	 * Can output image in one of this formats: png, gif, jpg.
	 * If you don`t give format, it will use 
	 * the format of image object.
	 *
	 * @param string $format
	 * @param string $file
	 */
	public function output($format=null,$file=null) {
		/**
		 * Если формат не указан, значит сохраняем формат исходного объекта
		 */
		if(is_null($format)) {
			$format=$this->format;
		}
		/**
		 * Производим преобразование и отдаем результат
		 */
		switch($format) {
			default:
			case 'png':
				$this->image->setFormat("png");
				if(!$file) {
					header("Content-type: image/png");
				}
				break;
			
			case 'jpg':
				$this->image->setFormat("jpg");
				if(!$file) {
					header("Content-type: image/jpeg");
				}
				break;
			
			case 'gif':
				$this->image->setFormat("gif");
				if(!$file) {
					header("Content-type: image/gif");
				}
				break;

            case 'webp':
                $this->image->setFormat("webp");
                if(!$file) {
                    header("Content-type: image/webp");
                }
                break;
        }

		if(!$file) {
			echo $this->image->getImageBlob();
		} else {
			file_put_contents($file, $this->image->getImageBlob());
		}

	}

	public function rgb($r=255,$g=255,$b=255) {
		return $this->setImageBackgroundColor(new \ImagickPixel("rgb($r, $g, $b)"));
	}

	public function set_last_error($id) {
		$this->last_err_text = $this->error_messages[$id];
		$this->last_err_num  = $id;
	}

	public function get_last_error() {
		return empty($this->last_err_num) ? false : $this->last_err_text;
	}

	public function clear_error() {
		$this->last_err_text='';
		$this->last_err_num=0;
	}

	/**
	 * Convert string to unicode for making text label using true type font.
	 *
	 * @param  string $text
	 * @param  string $from
	 * @return string
	 */
	protected function to_unicode($text,$from='w') {
		$text=convert_cyr_string($text,$from,'i');
		$uni='';

		for($i=0, $len=strlen($text); $i<$len; $i++)
		{
			$char=$text{$i};
			$code=ord($char);
			$uni.=($code>175) ? "&#".(1040+($code-176)).";" : $char;
		}

		return $uni;
	}

	public function destroy_all() {
		$this->image=null;

		return true;
	}
}
?>