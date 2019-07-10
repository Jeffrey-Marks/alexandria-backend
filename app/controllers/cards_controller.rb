require 'open-uri'
require 'json'

class CardsController < ApplicationController
  def index
    # @cards = Card.all
    @cards = Card.order(:name).first(50)
    render json: @cards
  end

  def by_format
    @cards = Card.order(:name).first(50)

    cards_by_format = @cards.select do |card|
      card.legalities[params[:format]] === "legal"
    end

    render json: cards_by_format
  end

  def update_image
    card_id = params[:cardId]
    if card_id
      card = Card.find(card_id)
      user = nil
    else
      image = params[:imageURL]
      image = image[0..image.index("?")-1]
      user = User.find_by("image ~* ?", image)
      card = Card.find_by("image_uris ~* ?", image)
    end

    if card
      updated_card = JSON.parse(open("https://api.scryfall.com/cards/#{card.scryfall_id}").read)

      card.update(image_uris: updated_card["image_uris"])

      if user
        user.update(image: card.image_uris["art_crop"])
      end
    else
      if user
        user.update(image: Card.all.sample.image_uris["art_crop"])
      end
    end

  end
end
